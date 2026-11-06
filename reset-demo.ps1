# reset-demo.ps1
# Resets the demo: deletes .\demo-site (if present) and copies .\demo-seed to .\demo-site.
# It only ever touches the demo-site folder next to this script. Nothing else is modified.
#
# Usage (from any directory):
#   powershell -ExecutionPolicy Bypass -File C:\Projects\vaaradhi\reset-demo.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($root)) {
    throw 'Run this script as a file (-File), not by pasting it, so its folder can be found.'
}

$seed   = [System.IO.Path]::GetFullPath((Join-Path $root 'demo-seed'))
$target = [System.IO.Path]::GetFullPath((Join-Path $root 'demo-site'))

# Safety: the target must be exactly <script folder>\demo-site.
$expected = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($root, 'demo-site'))
if ($target -ne $expected -or (Split-Path $target -Leaf) -ne 'demo-site') {
    throw "Refusing to continue: unexpected target path '$target'."
}

if (-not (Test-Path -LiteralPath $seed -PathType Container)) {
    throw "demo-seed folder not found at '$seed'."
}

if (Test-Path -LiteralPath $target) {
    Write-Host "Deleting $target"
    Remove-Item -LiteralPath $target -Recurse -Force
}

Write-Host "Copying $seed -> $target"
Copy-Item -LiteralPath $seed -Destination $target -Recurse

$count = (Get-ChildItem -LiteralPath $target -Recurse -File | Measure-Object).Count
Write-Host "Done. demo-site now has $count files."
