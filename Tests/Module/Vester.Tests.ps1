$manifestPath = "$PSScriptRoot\..\..\Vester\Vester.psd1"

Import-Module "$PSScriptRoot\..\..\Vester" -force

Describe -Tags 'VersionChecks' "Vester manifest" {
    $manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop

    It "has a valid manifest" {
        {
            $manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name in the manifest" {
        $manifest.Name | Should Be 'Vester'
    }

    It "has a valid guid in the manifest" {
        $manifest.Guid | Should Be 'cd038486-b669-4edb-a66d-bfe94c61b011'
    }

    It "has a valid version in the manifest" {
        $manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
}