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
