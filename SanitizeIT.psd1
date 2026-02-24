@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'SanitizeIT.psm1'

    # Version number of this module.
    ModuleVersion     = '0.0.1'

    # ID used to uniquely identify this module
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

    # Author of this module
    Author            = 'Urrel Monsels'

    # Company or vendor of this module
    CompanyName       = 'Internal'

    # Copyright statement for this module
    Copyright         = '(c) 2026. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'PowerShell-gebaseerde oplossing voor het veilig anonimiseren van organisatiedata.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'New-SanitizationInventory',
        'New-SanitizationMapping',
        'Invoke-Anonymization',
        'Test-SanitizedOutput',
        'Export-SanitizationReview',
        'Import-SanitizationDecision'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # List of all files packages with this module
    FileList          = @(
        'SanitizeIT.psm1',
        'SanitizeIT.psd1'
    )
}
