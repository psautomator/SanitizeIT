<#
.SYNOPSIS
    Orchestrates the complete sanitization flow in one command.

.DESCRIPTION
    Sequentially executes Inventory, Mapping, Anonymization, and Verification.
    Can be used with the -SkipReview switch for full automation without human intervention.

.PARAMETER InputPath
    The path to the source directory containing the data.

.PARAMETER ProjectName
    The name of the project/run. Defaults to "AutoRun".

.PARAMETER SkipReview
    If set, the tool skips the manual review step and directly generates a mapping based on all hits.

.PARAMETER WorkspacePath
    The directory where results are stored. Defaults to ".\workspace".

.EXAMPLE
    Invoke-FullSanitization -InputPath ".\data" -SkipReview -Verbose
    Runs the entire flow automatically for the .\data directory.

.NOTES
    Author: Urrel Monsels
    Part of the SanitizeIT project.
#>
function Invoke-FullSanitization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputPath,

        [Parameter(Mandatory = $false)]
        [string]$ProjectName = "AutoRun",

        [Parameter(Mandatory = $false)]
        [switch]$SkipReview, # If set, automatically replaces everything with confidence >= threshold

        [Parameter(Mandatory = $false)]
        [string]$WorkspacePath = ".\workspace"
    )

    process {
        Write-Host "--- SanitizeIT: Automatische Full-Flow ---" -ForegroundColor Yellow
        
        # 1. Phase 1: Inventory
        $Run = New-SanitizationInventory -InputPath $InputPath -ProjectName $ProjectName -WorkspacePath $WorkspacePath
        
        # 2. Phase 2: Mapping (Automatic if SkipReview is set)
        if ($SkipReview) {
            Write-Host "SkipReview set: Generating mapping automatically..." -ForegroundColor Gray
            $null = New-SanitizationMapping -InventoryPath $Run.InventoryFile
        }
        else {
            Write-Host "`nPAUSE: Please review the inventory CSV at: $($Run.RunFolder)\work\inventory\review.csv" -ForegroundColor Yellow
            Write-Host "After review, run: Invoke-Anonymization -WorkspacePath $($Run.RunFolder)" -ForegroundColor Cyan
            return $Run
        }

        # 3. Phase 3: Anonymization
        Invoke-Anonymization -WorkspacePath $Run.RunFolder
        
        # 4. Phase 4: Verification
        $Success = Test-SanitizedOutput -Path (Join-Path $Run.RunFolder "sanitized")
        
        if ($Success) {
            Write-Host "`nFull flow completed successfully!" -ForegroundColor Green
        }
        else {
            Write-Error "Full flow failed Quality Gate."
        }

        return $Run
    }
}
