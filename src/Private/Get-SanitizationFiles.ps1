function Get-SanitizationFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    process {
        Write-Verbose "Discovering files in: $Path"
        
        $ResolvedRoot = (Resolve-Path $Path).Path
        $Files = Get-ChildItem -Path $ResolvedRoot -Recurse -File
        
        $Results = foreach ($File in $Files) {
            $Extension = $File.Extension.ToLower()
            $Type = switch ($Extension) {
                ".csv" { "CSV" }
                ".json" { "JSON" }
                ".xml" { "CLIXML" } # Primary assumption for .xml in this context
                ".clixml" { "CLIXML" }
                default { "Unknown" }
            }

            # Ensure RelativePath is actually relative to the ResolvedRoot
            $RelativePath = $File.FullName.Replace($ResolvedRoot, "").TrimStart('\').TrimStart('/')

            [PSCustomObject]@{
                FullName     = $File.FullName
                RelativePath = $RelativePath
                Name         = $File.Name
                Extension    = $Extension
                Type         = $Type
                Size         = $File.Length
                Hash         = (Get-FileHash -Path $File.FullName -Algorithm SHA256).Hash
                LastModified = $File.LastWriteTime
            }
        }

        return $Results
    }
}
