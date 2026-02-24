<#
.SYNOPSIS
    Parses a file into PowerShell objects based on the detected type.

.DESCRIPTION
    Loads the content of a file (CSV, JSON, CLIXML) and converts it to PSCustomObjects.

.PARAMETER FileObject
    An object with FullName and Type (as returned by Get-SanitizationFiles).

.EXAMPLE
    $Files = Get-SanitizationFiles -Path "."
    $Objects = Read-SanitizationFile -FileObject $Files[0]

.NOTES
    Author: Urrel Monsels
    Part of the SanitizeIT project.
#>
function Read-SanitizationFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$FileObject
    )

    process {
        Write-Verbose "Parsing file: $($FileObject.FullName) as $($FileObject.Type)"
        
        try {
            switch ($FileObject.Type) {
                "CSV" {
                    return Import-Csv -Path $FileObject.FullName
                }
                "JSON" {
                    $Content = Get-Content -Raw -Path $FileObject.FullName
                    return $Content | ConvertFrom-Json
                }
                "CLIXML" {
                    return Import-Clixml -Path $FileObject.FullName
                }
                default {
                    Write-Warning "Unsupported file type: $($FileObject.Type) for file $($FileObject.FullName)"
                    return $null
                }
            }
        }
        catch {
            Write-Error "Failed to parse $($FileObject.FullName): $($_.Exception.Message)"
            return $null
        }
    }
}
