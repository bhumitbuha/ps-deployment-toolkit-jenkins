<#
    Test suite for Set-Baseline.ps1
#>

$passed = 0
$failed = 0

function Assert-True {
    param($Condition, $TestName)
    if ($Condition) {
        Write-Host "  PASS: $TestName"
        $script:passed++
    } else {
        Write-Host "  FAIL: $TestName"
        $script:failed++
    }
}

Write-Host "=== Test Suite: Set-Baseline.ps1 ==="

# Test 1: Script file exists
Assert-True (Test-Path ".\src\Set-Baseline.ps1") "Script file exists"

# Test 2: Generate a Dev baseline and verify output
$tempOut = ".\artifacts\test-baseline.json"
& pwsh -File ".\src\Set-Baseline.ps1" -OutputPath $tempOut -Environment Dev
Assert-True (Test-Path $tempOut) "Baseline file created"

# Test 3: Validate JSON is parseable
try {
    $json = Get-Content $tempOut -Raw | ConvertFrom-Json
    Assert-True ($null -ne $json) "Baseline output is valid JSON"
    Assert-True ($json.Environment -eq "Dev") "Environment field is correct"
    Assert-True ($json.Settings.FirewallEnabled -eq $true) "FirewallEnabled is set"
    Assert-True ($json.Settings.LogRetentionDays -eq 7) "Dev log retention is 7 days"
} catch {
    Write-Host "  FAIL: JSON parsing failed -- $_"
    $script:failed++
}

Write-Host ""
Write-Host "Results: $passed passed, $failed failed"
if ($failed -gt 0) { exit 1 } else { exit 0 }
