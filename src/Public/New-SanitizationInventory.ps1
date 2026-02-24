function New-SanitizationInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputPath,

        [Parameter(Mandatory = $false)]
        [string]$WorkspacePath = ".\workspace",

        [Parameter(Mandatory = $false)]
        [string]$PolicyPath = ".\policy\rules.psd1",

        [Parameter(Mandatory = $false)]
        [string]$ProjectName = "Default"
    )

    process {
        $RunId = "RUN_$(Get-Date -Format 'yyyyMMdd_HHmm')_$ProjectName"
        $RunFolder = Join-Path $WorkspacePath $RunId
        $InventoryFolder = Join-Path $RunFolder "work\inventory"
        
        Write-Verbose "Initializing workspace for Run $RunId"
        New-Item -ItemType Directory -Path $InventoryFolder -Force | Out-Null

        # 1. Load Policy
        if (-not (Test-Path $PolicyPath)) {
            throw "Policy file not found at $PolicyPath"
        }
        $Policy = Import-PowerShellDataFile -Path $PolicyPath

        # 2. Discovery
        $Files = Get-SanitizationFiles -Path $InputPath
        $FilesIndexFile = Join-Path $RunFolder "files_index.json"
        $Files | ConvertTo-Json -Depth 10 | Set-Content -Path $FilesIndexFile

        # 3. Parsing & Scanning
        $AllCandidates = @()
        foreach ($File in $Files) {
            Write-Host "Processing $($File.RelativePath)..." -ForegroundColor Cyan
            
            $Objects = Read-SanitizationFile -FileObject $File
            if ($null -eq $Objects) { continue }

            # Handle both single objects and arrays
            $ObjectArray = @($Objects)
            
            foreach ($Obj in $ObjectArray) {
                $Candidates = Find-SensitiveCandidates -InputObject $Obj -Policy $Policy -ContextFile $File.RelativePath
                $AllCandidates += $Candidates
            }
        }

        # 4. Normalization & Deduplication
        # We group by Value and Type to avoid redundancy
        $UniqueCandidates = $AllCandidates | Group-Object -Property Value, Type | ForEach-Object {
            $First = $_.Group[0]
            [PSCustomObject]@{
                Value       = $First.Value
                Type        = $First.Type
                Confidence  = ($_.Group | Measure-Object -Property Confidence -Maximum).Maximum
                Occurrences = $_.Count
                Evidence    = ($_.Group | Select-Object -ExpandProperty Evidence -Unique) -join "; "
                Contexts    = ($_.Group | Select-Object -ExpandProperty ContextFile -Unique)
            }
        }

        # 5. Write Artifacts
        $InventoryFile = Join-Path $InventoryFolder "inventory.json"
        $ClassificationFile = Join-Path $InventoryFolder "classification.json"

        $UniqueCandidates | ConvertTo-Json -Depth 10 | Set-Content -Path $InventoryFile
        
        # Classification is currently very similar to inventory, but we can separate it if needed
        # For now, we write the same set as a placeholder for more advanced classification logic
        $UniqueCandidates | ConvertTo-Json -Depth 10 | Set-Content -Path $ClassificationFile

        Write-Host "`nPhase 1 Complete!" -ForegroundColor Green
        Write-Host "Run ID: $RunId"
        Write-Host "Files Scanned: $($Files.Count)"
        Write-Host "Candidates Found: $($UniqueCandidates.Count)"
        Write-Host "Work folder: $RunFolder"

        return [PSCustomObject]@{
            RunId          = $RunId
            RunFolder      = $RunFolder
            InventoryFile  = $InventoryFile
            FilesScanned   = $Files.Count
            CandidateCount = $UniqueCandidates.Count
        }
    }
}
