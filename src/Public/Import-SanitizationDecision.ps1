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
