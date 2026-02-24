<#
.SYNOPSIS
    Scans a PowerShell object for sensitive data based on policy rules.

.DESCRIPTION
    Checks both property names (Schema rules) and property values (Value rules/Regex)
    to identify potential sensitive information. Assigns a confidence score and 
    provides evidence for the match.

.PARAMETER InputObject
    The PowerShell object (usually a PSCustomObject) to scan.

.PARAMETER Policy
    The policy object containing SchemaRules and Rules (Value-based).

.PARAMETER ContextFile
    The relative path of the file being scanned (for reporting purposes).

.EXAMPLE
    $Candidates = Find-SensitiveCandidates -InputObject $MyObj -Policy $MyPolicy -ContextFile "data.csv"

.NOTES
    Author: Urrel Monsels
    Part of the SanitizeIT project.
#>
function Find-SensitiveCandidates {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Policy,

        [Parameter(Mandatory = $true)]
        [string]$ContextFile
    )

    process {
        $Candidates = New-Object System.Collections.Generic.List[PSCustomObject]
        
        # Get all properties of the object
        $Properties = $InputObject.PSObject.Properties
        
        foreach ($Prop in $Properties) {
            $PropName = $Prop.Name
            $Value = [string]$Prop.Value
            
            # Skip empty or null values
            if ([string]::IsNullOrWhiteSpace($Value)) { continue }

            # --- IGNORE ALIASES ---
            # If the value looks like one of our aliases, skip it
            if ($Value -match "^(SVR|NET|USR|ID|SEC|VAL)-\d{3,5}$") {
                continue
            }

            $MatchedRule = $null
            $Evidence = ""
            $FinalScore = 0.0
            $Type = "Generic"

            # --- KANAAL A: Schema-based (Veldnaam) ---
            foreach ($Rule in $Policy.SchemaRules) {
                if ($PropName -like $Rule.Pattern) {
                    $MatchedRule = $Rule
                    $FinalScore = $Rule.Score
                    $Type = $Rule.Type
                    $Evidence = "Schema match: $PropName matches $($Rule.Pattern)"
                    break
                }
            }

            # --- KANAAL B: Value-based (Regex) ---
            # Try to match every regex rule against the value
            # Note: We scan even if Schema matched to increase confidence
            foreach ($Rule in $Policy.Rules) {
                if ($Value -match $Rule.Pattern) {
                    # If we already had a schema match, we increase confidence
                    if ($MatchedRule) {
                        $FinalScore = [Math]::Max($FinalScore, $Rule.Score) + 0.1
                        if ($FinalScore -gt 1.0) { $FinalScore = 1.0 }
                        $Evidence += " + Value match: $($Rule.Name)"
                    }
                    else {
                        $MatchedRule = $Rule
                        $FinalScore = $Rule.Score
                        $Type = $Rule.Type
                        $Evidence = "Value match: $($Rule.Name)"
                    }
                    # We continue to see if other regexes match (optional)
                }
            }

            if ($MatchedRule) {
                $Candidates.Add([PSCustomObject]@{
                        Value       = [string]$Value
                        PropName    = $PropName
                        Type        = $Type
                        Confidence  = $FinalScore
                        Evidence    = $Evidence
                        ContextFile = $ContextFile
                    })
            }
        }

        return $Candidates
    }
}
