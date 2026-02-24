<#
.SYNOPSIS
    Exports the identified candidates to a CSV for manual review.

.DESCRIPTION
    Creates an organized CSV file of all unique sensitive values found. 
    Adds an 'Action' column that defaults to 'Replace' or 'Review' based on the confidence score.

.PARAMETER InventoryPath
    The path to the inventory.json file.

.PARAMETER OutputPath
    The target path for the CSV file.

.EXAMPLE
    Export-SanitizationReview -InventoryPath ".\workspace\RUN_xxx\work\inventory\inventory.json" -OutputPath ".\review.csv"
    Generates a review file that can be opened in Excel.

.NOTES
    Author: Urrel Monsels
    Part of the SanitizeIT project.
#>
function Export-SanitizationReview {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InventoryPath,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        Write-Verbose "Exporting inventory for review: $InventoryPath"
        
        if (-not (Test-Path $InventoryPath)) {
            Write-Error "Inventory file not found: $InventoryPath"
            return
        }

        $Inventory = Get-Content -Raw -Path $InventoryPath | ConvertFrom-Json
        
        $ReviewItems = foreach ($Item in $Inventory) {
            # Determine default action based on confidence
            $Action = "Replace"
            if ($Item.Confidence -lt 0.7) {
                $Action = "Review"
            }
            if ($Item.Confidence -lt 0.4) {
                $Action = "Keep"
            }

            [PSCustomObject]@{
                Value         = $Item.Value
                Type          = $Item.Type
                Confidence    = $Item.Confidence
                Occurrences   = $Item.Occurrences
                Action        = $Action # Replace, Keep, Review
                TransformType = "Default" # Default, Random, Deterministic, Mask
                Evidence      = $Item.Evidence
                Contexts      = $Item.Contexts -join "; "
            }
        }

        $ReviewItems | Export-Csv -Path $OutputPath -NoTypeInformation -Delimiter ","
        Write-Host "Review CSV created at: $OutputPath" -ForegroundColor Green
    }
}
