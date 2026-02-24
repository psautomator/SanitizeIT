function New-SanitizationMapping {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InventoryPath,

        [Parameter(Mandatory = $false)]
        [string]$DecisionsPath,

        [Parameter(Mandatory = $false)]
        [string]$Salt = "DefaultSalt123" # In enterprise, this should be more secure
    )

    process {
        Write-Verbose "Generating Mapping from $InventoryPath"
        
        # 1. Load Inventory
        if (-not (Test-Path $InventoryPath)) {
            throw "Inventory file not found: $InventoryPath"
        }
        $Inventory = Get-Content -Raw -Path $InventoryPath | ConvertFrom-Json

        # 2. Load Decisions (Optional)
        $Decisions = @{}
        if ($DecisionsPath -and (Test-Path $DecisionsPath)) {
            $DecList = Get-Content -Raw -Path $DecisionsPath | ConvertFrom-Json
            foreach ($Dec in $DecList) {
                $Decisions[$Dec.Value] = $Dec
            }
        }

        # 3. Process each candidate
        $Mapping = @{}
        $Counters = @{} # To keep track of numbered aliases (e.g., SVR-001, SVR-002)

        foreach ($Item in $Inventory) {
            $Value = $Item.Value
            $Type = $Item.Type
            
            # Check if we should keep or replace
            $Action = "Replace" # Default
            if ($Decisions.ContainsKey($Value)) {
                $Action = $Decisions[$Value].Action
            }
            elseif ($Item.Confidence -lt 0.7) {
                $Action = "Review" # In mapping generation, "Review" without decision might default to Keep or a warning
            }

            if ($Action -eq "Keep") {
                continue
            }

            if ($Action -eq "Review") {
                Write-Warning "Candidate requires review and was skipped: $Value (Confidence: $($Item.Confidence))"
                continue
            }

            # Generate Alias
            $Prefix = switch ($Type) {
                "Infrastructure" { "SVR" }
                "Network" { "NET" }
                "Person" { "USR" }
                "Identity" { "ID" }
                "Secret" { "SEC" }
                default { "VAL" }
            }

            if (-not $Counters.ContainsKey($Prefix)) {
                $Counters[$Prefix] = 1
            }

            $AliasId = $Counters[$Prefix]++
            $Alias = "$Prefix-$(($AliasId).ToString('000'))"

            $Mapping[$Value] = [PSCustomObject]@{
                OriginalValue = $Value
                Alias         = $Alias
                Type          = $Type
                Action        = $Action
            }
        }

        # 4. Save Mapping
        $MappingFolder = Split-Path $InventoryPath -Parent
        if ($MappingFolder -like "*inventory*") {
            $MappingFolder = Join-Path (Split-Path $MappingFolder -Parent) "mappings"
        }
        else {
            $MappingFolder = Join-Path (Split-Path $InventoryPath -Parent) "mappings"
        }

        if (-not (Test-Path $MappingFolder)) {
            New-Item -ItemType Directory -Path $MappingFolder -Force | Out-Null
        }

        $MappingFile = Join-Path $MappingFolder "mapping.json"
        
        # Convert Hashtable to Array for JSON storage
        $MappingArray = $Mapping.Values | Sort-Object OriginalValue
        $MappingArray | ConvertTo-Json -Depth 10 | Set-Content -Path $MappingFile

        Write-Host "Mapping generated with $($MappingArray.Count) entries." -ForegroundColor Green
        Write-Host "Mapping file: $MappingFile"

        return [PSCustomObject]@{
            MappingFile = $MappingFile
            EntryCount  = $MappingArray.Count
        }
    }
}
