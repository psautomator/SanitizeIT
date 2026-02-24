function Invoke-SanitizationApply {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$InputObject,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Mapping
    )

    process {
        # Create a deep copy or work on the object
        # In PowerShell, PSCustomObjects are reference types, but we'll return a new one for safety if needed.
        # However, for simplicity and performance in large datasets, we'll modify properties.
        
        $Properties = $InputObject.PSObject.Properties
        foreach ($Prop in $Properties) {
            $Value = [string]$Prop.Value
            
            if ($Mapping.ContainsKey($Value)) {
                $Prop.Value = $Mapping[$Value].Alias
            }
            elseif ($Mapping.ContainsKey($Value.ToLower())) {
                # Case-insensitive fallback if canonical was lowercased
                $Prop.Value = $Mapping[$Value.ToLower()].Alias
            }
            # Note: We could add partial string replacement (regex-based) here if needed for free-text fields.
        }

        return $InputObject
    }
}
