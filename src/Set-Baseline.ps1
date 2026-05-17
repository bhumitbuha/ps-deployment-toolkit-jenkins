<#
.SYNOPSIS
    Generates a parameterized baseline configuration file.
.PARAMETER OutputPath
    Where to write the baseline JSON file.
.PARAMETER Environment
    Target environment: Dev, Staging, or Prod.
#>
param(
    [Parameter(Mandatory)]
    [string]$OutputPath,

    [ValidateSet("Dev", "Staging", "Prod")]
    [string]$Environment = "Dev"
)

function New-BaselineConfig {
    param([string]$Env)

    $config = @{
        Version     = "1.0.0"
        Environment = $Env
        GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Settings    = @{
            FirewallEnabled    = $true
            AutoUpdateEnabled  = ($Env -eq "Prod")
            LogRetentionDays   = switch ($Env) { "Dev" { 7 } "Staging" { 30 } "Prod" { 90 } }
            AllowedPorts       = @(443, 80, 22)
        }
    }

    return $config
}

$baseline = New-BaselineConfig -Env $Environment
$outputDir = Split-Path $OutputPath
if ($outputDir -and -not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }

$baseline | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "Baseline config written to: $OutputPath"
Write-Host "Environment: $Environment"
Write-Host "Log retention: $($baseline.Settings.LogRetentionDays) days"
