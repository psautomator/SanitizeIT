# tests\structure.tests.ps1

Describe "SanitizeIT Project Structure" {
    It "Should have all required folders" {
        $RequiredFolders = @("src", "policy", "workspace", "tests")
        foreach ($Folder in $RequiredFolders) {
            Path-Exists ".\$Folder" | Should -Be $true
        }
    }

    It "Should have the module manifest" {
        Path-Exists ".\SanitizeIT.psd1" | Should -Be $true
    }

    It "Should have the root module" {
        Path-Exists ".\SanitizeIT.psm1" | Should -Be $true
    }

    It "Should have the policy rules" {
        Path-Exists ".\policy\rules.psd1" | Should -Be $true
    }
}

Describe "SanitizeIT Module Loading" {
    BeforeAll {
        Import-Module ".\SanitizeIT.psd1" -Force
    }

    It "Should export the required public functions" {
        $ExportedFunctions = (Get-Module SanitizeIT).ExportedFunctions.Keys
        $ExpectedFunctions = @(
            "New-SanitizationInventory",
            "New-SanitizationMapping",
            "Invoke-Anonymization",
            "Test-SanitizedOutput"
        )
        foreach ($Func in $ExpectedFunctions) {
            $ExportedFunctions | Should -Contain $Func
        }
    }
}
