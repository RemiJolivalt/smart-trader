# Active la branch protection sur main et develop
param(
    [string]$Repo = "RemiJolivalt/smart-trader"
)
$ErrorActionPreference = "Stop"

$payload = @{
    required_status_checks = @{
        strict = $true
        contexts = @("ci-status")
    }
    enforce_admins = $false
    required_pull_request_reviews = @{
        required_approving_review_count = 1
        dismiss_stale_reviews = $true
        require_code_owner_reviews = $true
    }
    restrictions = $null
    required_linear_history = $true
    allow_force_pushes = $false
    allow_deletions = $false
    required_conversation_resolution = $true
} | ConvertTo-Json -Depth 6 -Compress

$tmp = New-TemporaryFile
[System.IO.File]::WriteAllText($tmp.FullName, $payload, (New-Object System.Text.UTF8Encoding $false))

foreach ($branch in @("main","develop")) {
    Write-Host "Protecting $branch..." -ForegroundColor Cyan
    & gh api -X PUT "repos/$Repo/branches/$branch/protection" --input $tmp.FullName | Out-Null
    Write-Host "OK: $branch"
}
Remove-Item $tmp -Force
