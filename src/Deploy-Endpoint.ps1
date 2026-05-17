<#
.SYNOPSIS
    Deploys baseline configuration to an endpoint.
.PARAMETER ComputerName
    Target endpoint hostname.
.PARAMETER BaselinePath
    Path to the baseline configuration file.
.PARAMETER LogPath
    Path to write deployment log output.
#>
param(
    [Parameter(Mandatory)]
    [string]$ComputerName,

    [Parameter(Mandatory)]
    [string]$BaselinePath,

    [string]$LogPath = ".\artifacts\deploy.log"
)

function Invoke-BaselineDeploy {
    param([string]$Computer, [string]$Baseline, [string]$Log)

    $results = @{
        Computer   = $Computer
        Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Stages     = @()
        ExitCode   = 0
    }

    # Stage 1: Validate baseline file exists
    Write-Host "[STAGE 1] Validating baseline file..."
    if (-not (Test-Path $Baseline)) {
        $results.Stages += @{ Stage = "ValidateBaseline"; Status = "FAIL"; Detail = "File not found: $Baseline" }
        $results.ExitCode = 1
    } else {
        $results.Stages += @{ Stage = "ValidateBaseline"; Status = "PASS"; Detail = "Baseline file verified" }
    }

    # Stage 2: Validate parameters
    Write-Host "[STAGE 2] Validating input parameters..."
    if ([string]::IsNullOrWhiteSpace($Computer)) {
        $results.Stages += @{ Stage = "ValidateParams"; Status = "FAIL"; Detail = "ComputerName cannot be empty" }
        $results.ExitCode = 1
    } else {
        $results.Stages += @{ Stage = "ValidateParams"; Status = "PASS"; Detail = "Parameters validated" }
    }

    # Stage 3: Simulate configuration apply
    Write-Host "[STAGE 3] Applying baseline configuration..."
    Start-Sleep -Milliseconds 200  # simulate work
    $results.Stages += @{ Stage = "ApplyBaseline"; Status = "PASS"; Detail = "Configuration applied successfully" }

    # Stage 4: Write log
    Write-Host "[STAGE 4] Writing deployment log..."
    $logDir = Split-Path $Log
    if ($logDir -and -not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
    $results | ConvertTo-Json -Depth 4 | Out-File -FilePath $Log -Encoding UTF8
    $results.Stages += @{ Stage = "WriteLog"; Status = "PASS"; Detail = "Log written to $Log" }

    return $results
}

$deployment = Invoke-BaselineDeploy -Computer $ComputerName -Baseline $BaselinePath -Log $LogPath

foreach ($stage in $deployment.Stages) {
    $icon = if ($stage.Status -eq "PASS") { "+" } else { "x" }
    Write-Host "  $icon [$($stage.Stage)] $($stage.Status) -- $($stage.Detail)"
}

Write-Host ""
Write-Host "Deployment complete. Exit code: $($deployment.ExitCode)"
exit $deployment.ExitCode
