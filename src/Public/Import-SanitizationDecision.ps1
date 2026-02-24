<#
.SYNOPSIS
    Imports decisions from an edited review CSV file.

.DESCRIPTION
    Reads the CSV edited by the user and filters for rows where the action is 'Replace' or 'Keep'.
    Saves these as decisions.json for use in the mapping phase.

.PARAMETER CSVPath
    The path to the edited review CSV.

.PARAMETER OutputPath
    The target path for the decisions.json file.

.EXAMPLE
    Import-SanitizationDecision -CSVPath ".\review_done.csv" -OutputPath ".\decisions.json"
    Converts the CSV to a machine-readable JSON format.

.NOTES
    Author: Urrel Monsels
    Part of the SanitizeIT project.
#>
function Import-SanitizationDecision {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CSVPath,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    process {
        Write-Verbose "Importing decisions from: $CSVPath"
        
        if (-not (Test-Path $CSVPath)) {
            Write-Error "Decision CSV not found: $CSVPath"
            return
        }

        $CSV = Import-Csv -Path $CSVPath -Delimiter ","
        $Decisions = foreach ($Row in $CSV) {
            # Filter only rows that need specific action
            if ($Row.Action -in @("Replace", "Keep")) {
                [PSCustomObject]@{
                    Value         = $Row.Value
                    Type          = $Row.Type
                    Action        = $Row.Action
                    TransformType = $Row.TransformType
                }
            }
        }

        $Decisions | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath
        Write-Host "Decisions JSON created at: $OutputPath" -ForegroundColor Green
    }
}
