# setup-workspaces.ps1
# Creates the Vaaradhi agent workspaces from this repo.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\setup-workspaces.ps1 -ProductionUrl https://<your-project>.vercel.app
#   powershell -ExecutionPolicy Bypass -File .\setup-workspaces.ps1 -ProductionUrl https://<your-project>.vercel.app -AgentsRoot D:\VaaradhiAgents
#
# It refuses to run if AgentsRoot already exists, so it never overwrites a workspace.
# It does not run vercel, git, or anything in Switch. It prints those steps at the end.

param(
    [string]$AgentsRoot = 'C:\VaaradhiAgents',
    [Parameter(Mandatory = $true)]
    [string]$ProductionUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Repo = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Repo)) { throw 'Run this script as a file (-File), not by pasting it.' }

# ---------- Validate inputs ----------
$AgentsRoot = [System.IO.Path]::GetFullPath($AgentsRoot).TrimEnd('\')
$ProductionUrl = $ProductionUrl.Trim().TrimEnd('/')
if ($ProductionUrl -notmatch '^https://[^/\s]+$') {
    throw "ProductionUrl must look like https://your-project.vercel.app (got '$ProductionUrl')."
}
if (Test-Path -LiteralPath $AgentsRoot) {
    throw "AgentsRoot '$AgentsRoot' already exists. Refusing to overwrite it. Choose another -AgentsRoot or remove that folder yourself."
}

$Seed    = Join-Path $Repo 'demo-seed'
$Changes = Join-Path $Repo 'changes'
$AgentFiles = @{
    'team'    = @('CLAUDE.md', 'shot.js', 'package.json')
    'breaker' = @('AGENTS.md', 'shot.js', 'package.json')
}

foreach ($dir in @($Seed, $Changes)) {
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { throw "Missing repo folder: $dir" }
}
foreach ($pr in 'PR-1', 'PR-2', 'PR-3') {
    if (-not (Test-Path -LiteralPath (Join-Path $Changes $pr) -PathType Container)) { throw "Missing repo folder: changes\$pr" }
}
foreach ($role in $AgentFiles.Keys) {
    foreach ($f in $AgentFiles[$role]) {
        $src = Join-Path $Repo "agents\$role\$f"
        if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { throw "Missing repo file: agents\$role\$f" }
    }
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node.js was not found on PATH (Node 22 or later is needed).' }
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw 'npm was not found on PATH.' }

$Team    = Join-Path $AgentsRoot 'team'
$Breaker = Join-Path $AgentsRoot 'breaker'

# ---------- Folders ----------
Write-Host "1/5 Creating folders under $AgentsRoot"
foreach ($d in @(
        (Join-Path $Team 'incoming'), (Join-Path $Team 'work'), (Join-Path $Team 'evidence'),
        (Join-Path $Breaker 'incoming'), (Join-Path $Breaker 'shots'))) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

# ---------- Agent files with placeholders filled ----------
Write-Host '2/5 Copying agent files (filling {{AGENTS_ROOT}} and {{PRODUCTION_URL}})'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
foreach ($role in $AgentFiles.Keys) {
    $destDir = Join-Path $AgentsRoot $role
    foreach ($f in $AgentFiles[$role]) {
        $text = [System.IO.File]::ReadAllText((Join-Path $Repo "agents\$role\$f"), $utf8NoBom)
        $text = $text.Replace('{{AGENTS_ROOT}}', $AgentsRoot).Replace('{{PRODUCTION_URL}}', $ProductionUrl)
        if ($text -match '\{\{[A-Z_]+\}\}') { throw "Unfilled placeholder left in agents\$role\$f." }
        [System.IO.File]::WriteAllText((Join-Path $destDir $f), $text, $utf8NoBom)
    }
}

# ---------- Site and incoming changes ----------
Write-Host '3/5 Copying demo-seed to team\site'
Copy-Item -LiteralPath $Seed -Destination (Join-Path $Team 'site') -Recurse

Write-Host '4/5 Copying changes\PR-1..PR-3 into team\incoming and breaker\incoming'
foreach ($pr in 'PR-1', 'PR-2', 'PR-3') {
    Copy-Item -LiteralPath (Join-Path $Changes $pr) -Destination (Join-Path $Team "incoming\$pr") -Recurse
    Copy-Item -LiteralPath (Join-Path $Changes $pr) -Destination (Join-Path $Breaker "incoming\$pr") -Recurse
}

# ---------- Playwright (uses the installed Chrome; no browser download) ----------
Write-Host '5/5 npm install playwright in team and breaker (PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1)'
$previousSkip = $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD
$env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = '1'
try {
    foreach ($dir in @($Team, $Breaker)) {
        Push-Location -LiteralPath $dir
        try {
            & npm install playwright --no-fund --no-audit
            if ($LASTEXITCODE -ne 0) { throw "npm install failed in $dir (exit code $LASTEXITCODE)." }
        } finally {
            Pop-Location
        }
    }
} finally {
    $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = $previousSkip
}

# ---------- Next steps ----------
$teamDir = $Team
$breakerDir = $Breaker
Write-Host ''
Write-Host "Workspaces created in $AgentsRoot"
Write-Host ''
Write-Host 'NEXT STEPS (do these yourself):'
Write-Host ''
Write-Host '1. Link team\site to your own Vercel project and deploy the starting site:'
Write-Host "     cd `"$teamDir\site`""
Write-Host '     vercel link'
Write-Host '     vercel deploy --prod'
Write-Host "   Your production URL must be $ProductionUrl. If Vercel gives a different one,"
Write-Host '   delete this AgentsRoot and run this script again with the real URL.'
Write-Host ''
Write-Host '2. Turn off preview deployment protection, so the agents can screenshot previews:'
Write-Host '     Vercel dashboard > your project > Settings > Deployment Protection >'
Write-Host '     Vercel Authentication > Disabled, then Save.'
Write-Host ''
Write-Host '3. Let the Codex breaker reach the internet and write in its folder. In'
Write-Host "     $env:USERPROFILE\.codex\config.toml"
Write-Host '   put this line at the very top (above any [section] header):'
Write-Host '     sandbox_mode = "workspace-write"'
Write-Host '   and add this section:'
Write-Host '     [sandbox_workspace_write]'
Write-Host '     network_access = true'
Write-Host ''
Write-Host '4. Create the agents and the room from the template:'
Write-Host '     Switch Console > Templates > Import template > paste vaaradhi.template.yaml'
Write-Host '     Then select Use and fill in:'
Write-Host "       Team folder:    $teamDir"
Write-Host "       Breaker folder: $breakerDir"
