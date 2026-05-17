<#
    Test suite for Deploy-Endpoint.ps1
    Uses assertion-based pass/fail pattern.
#>

$ErrorActionPreference = "Stop"
$testResults = @()
$passed = 0
$failed = 0

function Assert-Equal {
    param($Actual, $Expected, $TestName)
    if ($Actual -eq $Expected) {
        Write-Host "  PASS: $TestName"
        $script:passed++
        return @{ Test = $TestName; Status = "PASS" }
    } else {
        Write-Host "  FAIL: $TestName (expected '$Expected', got '$Actual')"
        $script:failed++
        return @{ Test = $TestName; Status = "FAIL"; Expected = $Expected; Actual = $Actual }
    }
}

function Assert-True {
    param($Condition, $TestName)
    if ($Condition) {
        Write-Host "  PASS: $TestName"
        $script:passed++
        return @{ Test = $TestName; Status = "PASS" }
    } else {
        Write-Host "  FAIL: $TestName (condition was false)"
        $script:failed++
        return @{ Test = $TestName; Status = "FAIL" }
    }
}

Write-Host "=== Test Suite: Deploy-Endpoint.ps1 ==="

# Test 1: Script file exists
$testResults += Assert-True (Test-Path ".\src\Deploy-Endpoint.ps1") "Script file exists"

# Test 2: Script has required param block
$content = Get-Content ".\src\Deploy-Endpoint.ps1" -Raw
$testResults += Assert-True ($content -match "param\(") "Script has param block"

# Test 3: Script contains Mandatory parameter
$testResults += Assert-True ($content -match "\[Parameter\(Mandatory\)\]") "Script has Mandatory parameters"

# Test 4: Script contains exit code logic
$testResults += Assert-True ($content -match "ExitCode") "Script implements exit code tracking"

# Test 5: Script contains stage logging
$testResults += Assert-True ($content -match "STAGE") "Script implements stage-based logging"

# Test 6: Script contains log writing
$testResults += Assert-True ($content -match "Out-File") "Script writes output to log file"

# Test 7: Run the script with a valid baseline and check exit 0
$tempBaseline = [System.IO.Path]::GetTempFileName()
"{}" | Out-File $tempBaseline -Encoding UTF8
$process = Start-Process pwsh -ArgumentList "-File", ".\src\Deploy-Endpoint.ps1", "-ComputerName", "TEST-PC", "-BaselinePath", "$tempBaseline", "-LogPath", ".\artifacts\test-deploy.log" -Wait -PassThru -NoNewWindow
$testResults += Assert-Equal $process.ExitCode 0 "Script exits 0 with valid inputs"
Remove-Item $tempBaseline -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Results: $passed passed, $failed failed"

if ($failed -gt 0) {
    Write-Host "TEST SUITE FAILED"
    exit 1
} else {
    Write-Host "TEST SUITE PASSED"
    exit 0
}
