# Sync labels GitHub depuis infra/github/labels.yml
# Usage: pwsh -File scripts/sync-labels.ps1
param(
    [string]$LabelsFile = "infra/github/labels.yml",
    [string]$Repo = "RemiJolivalt/smart-trader"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $LabelsFile)) {
    throw "Labels file not found: $LabelsFile"
}

$rawLines = Get-Content $LabelsFile | Where-Object { $_ -notmatch '^\s*#' }
$content = ($rawLines -join "`n")
# Parse minimaliste : blocs séparés par "- name:"
$blocks = ($content -split "(?m)^\s*-\s*name:\s*") | Where-Object { $_.Trim() }

foreach ($block in $blocks) {
    $lines = $block -split "`n"
    $name = $lines[0].Trim()
    $color = ""
    $desc = ""
    foreach ($line in $lines[1..($lines.Length - 1)]) {
        if ($line -match '^\s*color:\s*"?([^"]+)"?\s*$') { $color = $Matches[1].Trim('"') }
        if ($line -match '^\s*description:\s*"?(.+?)"?\s*$') { $desc = $Matches[1].Trim('"') }
    }
    if (-not $name) { continue }

    Write-Host "Sync label: $name (#$color)" -ForegroundColor Cyan
    $args = @("label", "create", $name, "--repo", $Repo, "--force")
    if ($color) { $args += @("--color", $color) }
    if ($desc)  { $args += @("--description", $desc) }
    & gh @args | Out-Null
}

Write-Host "Done." -ForegroundColor Green
