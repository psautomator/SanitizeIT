<#
.SYNOPSIS
    Performs a quality check on the anonymized output.

.DESCRIPTION
    Re-scans the specified directory (usually the 'sanitized' folder) with the current rules. 
    If values with a high Confidence (leaks) are still found, the Quality Gate fails.

.PARAMETER Path
    The path to the anonymized files.

.PARAMETER PolicyPath
    The path to the rules file. Defaults to ".\policy\rules.psd1".

.PARAMETER Threshold
    The confidence threshold after which a match is considered a leak. Defaults to 0.7.

.EXAMPLE
    Test-SanitizedOutput -Path ".\workspace\RUN_xxx\sanitized"
    Checks if the sanitized files truly contain no more sensitive data.

.NOTES
    Author: Urrel Monsels
    Part of the SanitizeIT project.
#>
function Test-SanitizedOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$PolicyPath = ".\policy\rules.psd1",

        [Parameter(Mandatory = $false)]
        [double]$Threshold = 0.7
    )

    process {
        Write-Host "Starting Quality Gate scan on: $Path" -ForegroundColor Cyan
        
        # 1. Load Policy
        if (-not (Test-Path $PolicyPath)) {
            throw "Policy file not found at $PolicyPath"
        }
        $Policy = Import-PowerShellDataFile -Path $PolicyPath

        # 2. Discovery on Sanitized Path
        $Files = Get-SanitizationFiles -Path $Path
        
        $Failures = @()

        # 3. Scan each file
        foreach ($File in $Files) {
            Write-Verbose "Re-scanning $($File.RelativePath)..."
            
            $Objects = Read-SanitizationFile -FileObject $File
            if ($null -eq $Objects) { continue }

            $ObjectArray = @($Objects)
            foreach ($Obj in $ObjectArray) {
                $Leaks = Find-SensitiveCandidates -InputObject $Obj -Policy $Policy -ContextFile $File.RelativePath
                
                # Filter for high confidence leaks
                $HighConfidenceLeaks = $Leaks | Where-Object { $_.Confidence -ge $Threshold }
                if ($HighConfidenceLeaks) {
                    $Failures += $HighConfidenceLeaks
                }
            }
        }

        # 4. Report
        if ($Failures.Count -gt 0) {
            Write-Error "QUALITY GATE FAILED: $($Failures.Count) high-confidence candidates found in sanitized output!"
            $Failures | Select-Object Value, Type, Confidence, ContextFile | Format-Table
            return $false
        }
        else {
            Write-Host "QUALITY GATE PASSED: No high-confidence sensitive data detected." -ForegroundColor Green
            return $true
        }
    }
}
