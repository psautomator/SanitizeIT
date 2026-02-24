# SanitizeIT.psm1

$PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\src\Public\*.ps1" -Recurse
$PrivateFunctions = Get-ChildItem -Path "$PSScriptRoot\src\Private\*.ps1" -Recurse

foreach ($File in $PrivateFunctions) {
    try {
        . $File.FullName
    }
    catch {
        Write-Error "Failed to load private function from $($File.FullName): $($_.Exception.Message)"
    }
}

foreach ($File in $PublicFunctions) {
    try {
        . $File.FullName
    }
    catch {
        Write-Error "Failed to load public function from $($File.FullName): $($_.Exception.Message)"
    }
}

# Export functions
Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\src\Public\*.ps1" | ForEach-Object { $_.BaseName })
