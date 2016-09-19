$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$manifestPath = "$here\..\..\Vester\Vester.psd1"

Import-Module "$here\..\..\Vester" -force

Describe -Tags 'VersionChecks' "Vester manifest" {
    $script:manifest = $null
    It "has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name in the manifest" {
        $script:manifest.Name | Should Be 'Vester'
    }

    It "has a valid guid in the manifest" {
        $script:manifest.Guid | Should Be 'cd038486-b669-4edb-a66d-bfe94c61b011'
    }

    It "has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
}