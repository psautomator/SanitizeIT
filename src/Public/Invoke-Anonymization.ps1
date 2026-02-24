function Invoke-Anonymization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath, # Path to the Run folder (e.g. .\workspace\RUN_xxx)

        [Parameter(Mandatory = $false)]
        [string]$MappingPath, # If not provided, assumed in workspace

        [Parameter(Mandatory = $false)]
        [string]$OutputPath # If not provided, assumed in workspace\sanitized
    )

    process {
        Write-Verbose "Starting Phase 3: Anonimiseren in $WorkspacePath"

        # 1. Paths Setup
        $FilesIndexFile = Join-Path $WorkspacePath "files_index.json"
        if (-not (Test-Path $FilesIndexFile)) {
            throw "Files index not found in $FilesIndexFile"
        }

        if (-not $MappingPath) {
            $MappingPath = Join-Path $WorkspacePath "work\mappings\mapping.json"
        }

        if (-not $OutputPath) {
            $OutputPath = Join-Path $WorkspacePath "sanitized"
        }

        if (-not (Test-Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        }

        # 2. Load Mapping
        Write-Verbose "Loading mapping from $MappingPath"
        $MappingArray = Get-Content -Raw -Path $MappingPath | ConvertFrom-Json
        $MappingLookup = @{}
        foreach ($Entry in $MappingArray) {
            $MappingLookup[$Entry.OriginalValue] = $Entry
        }

        # 3. Load Files Index
        $Files = Get-Content -Raw -Path $FilesIndexFile | ConvertFrom-Json

        # 4. Process Files
        foreach ($File in $Files) {
            Write-Host "Sanitizing $($File.RelativePath)..." -ForegroundColor Cyan
            
            $Objects = Read-SanitizationFile -FileObject $File
            if ($null -eq $Objects) { continue }

            $ObjectArray = @($Objects)
            $SanitizedObjects = foreach ($Obj in $ObjectArray) {
                Invoke-SanitizationApply -InputObject $Obj -Mapping $MappingLookup
            }

            # Export
            $TargetFile = Join-Path $OutputPath $File.RelativePath
            $TargetDir = Split-Path $TargetFile -Parent
            if (-not (Test-Path $TargetDir)) {
                New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            }

            switch ($File.Type) {
                "CSV" {
                    $SanitizedObjects | Export-Csv -Path $TargetFile -NoTypeInformation -Delimiter ","
                }
                "JSON" {
                    $SanitizedObjects | ConvertTo-Json -Depth 10 | Set-Content -Path $TargetFile
                }
                "CLIXML" {
                    $SanitizedObjects | Export-Clixml -Path $TargetFile
                }
            }
        }

        Write-Host "`nAnonymization Complete!" -ForegroundColor Green
        Write-Host "Sanitized files located in: $OutputPath"

        return [PSCustomObject]@{
            OutputPath     = $OutputPath
            FilesProcessed = $Files.Count
        }
    }
}
