# reset-all.ps1
# Resets the whole Vaaradhi demo for a new run. Run it yourself:
#   powershell -ExecutionPolicy Bypass -File .\reset-all.ps1
#   powershell -ExecutionPolicy Bypass -File .\reset-all.ps1 -AgentsRoot D:\VaaradhiAgents -ProductionUrl https://<your-project>.vercel.app
#
# Parameters:
#   -AgentsRoot     the workspace folder made by setup-workspaces.ps1 (default C:\VaaradhiAgents)
#   -ProductionUrl  your production URL (default https://shipfest-2026.vercel.app)
#
# What it does, in order:
#   1. Checks everything it needs BEFORE changing anything, including that
#      team\site\.vercel is linked to the Vercel project behind ProductionUrl.
#   2. Archives <AgentsRoot>\team\evidence and <AgentsRoot>\breaker\shots
#      into <repo>\runs\<yyyyMMdd-HHmmss>\ and checks the copy.
#   3. Empties team\work, team\evidence and breaker\shots (the folders stay).
#   4. Replaces team\site with a fresh copy of demo-seed, keeping team\site\.vercel.
#   5. Deploys team\site to PRODUCTION (vercel deploy --prod --yes), so the live
#      site has the original bugs again, and prints the production URL.
#
# It touches only: runs\ (adds a folder), team\work, team\evidence, team\site,
# breaker\shots. It reads demo-seed. Nothing else is modified.
# Tip: stop any running agent sessions in Switch Console first.

param(
    [string]$AgentsRoot = 'C:\VaaradhiAgents',
    [string]$ProductionUrl = 'https://shipfest-2026.vercel.app'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    throw 'Run this script as a file (-File), not by pasting it.'
}

$AgentsRoot = [System.IO.Path]::GetFullPath($AgentsRoot).TrimEnd('\')
$ProductionUrl = $ProductionUrl.Trim().TrimEnd('/')
if ($ProductionUrl -notmatch '^https://[^/\s]+$') {
    throw "ProductionUrl must look like https://your-project.vercel.app (got '$ProductionUrl')."
}

$Seed        = Join-Path $ProjectRoot 'demo-seed'
$RunsRoot    = Join-Path $ProjectRoot 'runs'
$Team        = Join-Path $AgentsRoot 'team'
$Breaker     = Join-Path $AgentsRoot 'breaker'
$Site        = Join-Path $Team 'site'
$Work        = Join-Path $Team 'work'
$Evidence    = Join-Path $Team 'evidence'
$Shots       = Join-Path $Breaker 'shots'
$ProjectJson = Join-Path $Site '.vercel\project.json'
$ProdUrl     = $ProductionUrl

function Get-FileCount([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    return @(Get-ChildItem -LiteralPath $Path -Recurse -Force -File).Count
}

function Clear-Folder([string]$Path) {
    # Deletes everything inside $Path but keeps $Path itself.
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        return
    }
    Get-ChildItem -LiteralPath $Path -Force | Remove-Item -Recurse -Force
}

# ---------- 1. Pre-checks (nothing is changed if any of these fail) ----------
Write-Host '1/5 Checking prerequisites...'
foreach ($dir in @($Seed, $Team, $Breaker, $Site)) {
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { throw "Missing folder: $dir" }
}
if (Test-Path -LiteralPath (Join-Path $Seed '.vercel')) {
    throw "demo-seed contains a .vercel folder. Remove it first; the seed must not be linked to a Vercel project."
}
if (-not (Test-Path -LiteralPath $ProjectJson -PathType Leaf)) {
    throw "Missing $ProjectJson. team\site is not linked to Vercel; refusing to deploy."
}
$project = Get-Content -Raw -LiteralPath $ProjectJson | ConvertFrom-Json
$linkedName = [string]$project.projectName
if ([string]::IsNullOrWhiteSpace($linkedName)) {
    throw "$ProjectJson has no projectName. Run 'vercel link' in team\site first. Refusing to continue."
}
# The linked project must be the one behind ProductionUrl, so we never deploy over someone else's site.
$prodHost = ([System.Uri]$ProdUrl).Host
if ($prodHost -like '*.vercel.app') {
    $subdomain = $prodHost.Substring(0, $prodHost.Length - '.vercel.app'.Length)
    if ($subdomain -ne $linkedName -and -not $subdomain.StartsWith("$linkedName-")) {
        throw "team\site\.vercel is linked to '$linkedName', but ProductionUrl is $ProdUrl. Refusing to continue."
    }
} else {
    Write-Warning "ProductionUrl uses a custom domain, so it can't be matched to the linked project name '$linkedName'. Make sure that is the right project."
}
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    throw 'The vercel CLI was not found on PATH.'
}

# ---------- 2. Archive evidence and shots ----------
$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
$archive = Join-Path $RunsRoot $stamp
Write-Host "2/5 Archiving to $archive"
if (Test-Path -LiteralPath $archive) { throw "Archive folder already exists: $archive" }
New-Item -ItemType Directory -Path $archive -Force | Out-Null

$pairs = @(
    @{ Source = $Evidence; Dest = (Join-Path $archive 'team-evidence') },
    @{ Source = $Shots;    Dest = (Join-Path $archive 'breaker-shots') }
)
foreach ($p in $pairs) {
    if (Test-Path -LiteralPath $p.Source) {
        Copy-Item -LiteralPath $p.Source -Destination $p.Dest -Recurse
    } else {
        New-Item -ItemType Directory -Path $p.Dest | Out-Null
    }
    $src = Get-FileCount $p.Source
    $dst = Get-FileCount $p.Dest
    if ($src -ne $dst) { throw "Archive check failed for $($p.Source): $src files, archived $dst. Nothing was deleted." }
    Write-Host "    $($p.Source): $dst files archived"
}

# ---------- 3. Empty work, evidence and shots ----------
Write-Host '3/5 Emptying team\work, team\evidence, breaker\shots'
Clear-Folder $Work
Clear-Folder $Evidence
Clear-Folder $Shots

# ---------- 4. Fresh site from demo-seed, keeping .vercel ----------
Write-Host '4/5 Replacing team\site with demo-seed (keeping .vercel)'
Get-ChildItem -LiteralPath $Site -Force | Where-Object { $_.Name -ne '.vercel' } | Remove-Item -Recurse -Force
Get-ChildItem -LiteralPath $Seed -Force | Copy-Item -Destination $Site -Recurse -Force

foreach ($f in Get-ChildItem -LiteralPath $Seed -Recurse -File -Force) {
    $rel    = $f.FullName.Substring($Seed.Length)
    $target = Join-Path $Site $rel
    if (-not (Test-Path -LiteralPath $target)) { throw "Copy check failed: $target is missing." }
    if ((Get-FileHash -LiteralPath $f.FullName).Hash -ne (Get-FileHash -LiteralPath $target).Hash) {
        throw "Copy check failed: $target differs from demo-seed."
    }
}
if (-not (Test-Path -LiteralPath $ProjectJson)) { throw '.vercel was lost from team\site. Not deploying.' }

# ---------- 5. Deploy to production ----------
Write-Host '5/5 Deploying team\site to PRODUCTION (vercel deploy --prod --yes)...'
Push-Location -LiteralPath $Site
try {
    $output = & vercel deploy --prod --yes
    $exit = $LASTEXITCODE
} finally {
    Pop-Location
}
if ($exit -ne 0) { throw "vercel deploy failed with exit code $exit." }

$deployUrl = @($output | Where-Object { $_ -match '^https://' }) | Select-Object -Last 1

Write-Host ''
Write-Host 'Reset complete.'
Write-Host "Archive:        $archive"
if ($deployUrl) { Write-Host "Deployment URL: $deployUrl" }
Write-Host "Production URL: $ProdUrl"
