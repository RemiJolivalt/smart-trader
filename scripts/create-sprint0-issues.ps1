# Crée les issues Sprint 0 sur GitHub depuis scripts/sprint0-issues.txt
# Usage: pwsh -File scripts/create-sprint0-issues.ps1
param(
    [string]$Repo = "RemiJolivalt/smart-trader",
    [string]$Milestone = "Sprint 0 - Fondations",
    [string]$File = "scripts/sprint0-issues.txt"
)
$ErrorActionPreference = "Stop"

$raw = Get-Content $File -Raw
$blocks = ($raw -split "(?m)^---ISSUE---\s*$") | Where-Object { $_.Trim() }

foreach ($block in $blocks) {
    $title = ""
    $labels = ""
    $bodyLines = @()
    $inBody = $false

    foreach ($line in ($block -split "`r?`n")) {
        if (-not $inBody) {
            if ($line -match '^\s*title:\s*(.+)$')  { $title  = $Matches[1].Trim(); continue }
            if ($line -match '^\s*labels:\s*(.+)$') { $labels = $Matches[1].Trim(); continue }
            if ($line -match '^\s*body:\s*$')       { $inBody = $true; continue }
        } else {
            $bodyLines += $line
        }
    }

    if (-not $title) { continue }

    $body = ($bodyLines -join "`n").Trim()
    $tmp = New-TemporaryFile
    Set-Content -Path $tmp -Value $body -Encoding UTF8

    Write-Host "Create: $title" -ForegroundColor Cyan
    $args = @("issue","create","--repo",$Repo,"--title",$title,"--body-file",$tmp.FullName,"--milestone",$Milestone)
    if ($labels) { $args += @("--label", $labels) }
    & gh @args
    Remove-Item $tmp -Force
}
