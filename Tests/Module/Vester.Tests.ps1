# Test Vester .psd1, .psm1, general module structure, and function availability

Get-Module Vester | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\Vester" -Force

Describe 'Check module files for breaking changes' {
    $ModuleRoot = "$PSScriptRoot\..\..\Vester"
    $PublicFiles = (Get-ChildItem "$ModuleRoot\Public").BaseName

    It 'Contains expected helper files and directories' {
        "$ModuleRoot\Configs\readme.txt" | Should Exist
        "$ModuleRoot\en-US\about_Vester.help.txt" | Should Exist
        "$ModuleRoot\Private\Template\VesterTemplate.Tests.ps1" | Should Exist
        "$ModuleRoot\Public" | Should Exist
        "$ModuleRoot\Tests" | Should Exist
        "$ModuleRoot\..\LICENSE" | Should Exist
        "$ModuleRoot\..\README.md" | Should Exist
    }

    Context 'Verify .psd1 module file' {
        It 'Has a valid .psd1 module manifest' {
            {Test-ModuleManifest -Path "$ModuleRoot\Vester.psd1" -ErrorAction Stop -WarningAction SilentlyContinue} | Should Not Throw
        }

        $manifest = Test-ModuleManifest -Path "$ModuleRoot\Vester.psd1" -ErrorAction Stop

        It 'Static .psd1 values have not changed' {
            $manifest.RootModule | Should BeExactly 'Vester.psm1'
            $manifest.Name | Should BeExactly 'Vester'
            $manifest.Version -as [Version] | Should BeGreaterThan '1.0.0'
            $manifest.Guid | Should BeExactly 'cd038486-b669-4edb-a66d-bfe94c61b011'
            $manifest.Author | Should BeExactly 'Chris Wahl'
            $manifest.CompanyName | Should BeExactly 'Community'
            $manifest.Copyright | Should BeExactly 'Apache License'
            $manifest.Description | Should BeOfType String
            $manifest.PowerShellVersion | Should Be '3.0'
            # TODO: Need to rewrite this? Issue #74
            $manifest.RequiredModules | Should BeExactly 'Pester'
            $manifest.ExportedFunctions.Values.Name | Should BeExactly $PublicFiles

            $manifest.PrivateData.PSData.Tags | Should BeExactly @('vester','vmware','vcenter','vsphere','esxi','powercli')
            $manifest.PrivateData.PSData.LicenseUri | Should BeExactly 'https://github.com/WahlNetwork/Vester/blob/master/LICENSE'
            $manifest.PrivateData.PSData.ProjectUri | Should BeExactly 'https://github.com/WahlNetwork/Vester'
            # TODO: .ExternalModuleDependencies ?
        }

        It 'Exports all functions within the Public folder' {
            (Get-Command -Module Vester).Name | Should BeExactly $PublicFiles
        }
    }

    # InModuleScope helps test private functions
    InModuleScope Vester {
        # Run unit tests for all private functions here
        # Instead of breaking out into individual files like the public functions
        Context 'Contains expected private functions' {
            It 'Read-HostColor behaves normally' {
                Mock Write-Host {} -Verifiable
                Mock Read-Host {return 'rh-Test'} -Verifiable

                Read-HostColor | Should BeExactly 'rh-Test'

                # Ensure that Write-Host & Read-Host were actually called within Read-HostColor
                Assert-MockCalled Write-Host
                Assert-MockCalled Read-Host
            }

            # (Any additional private functions as It tests here)
        } #Context private
    } #InModuleScope
} #Describe
