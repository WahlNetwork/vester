# Test Vester .psd1, .psm1, general module structure, and function availability

Get-Module Vester | Remove-Module -Force
Import-Module "$PSScriptRoot\..\..\Vester" -Force

Describe 'Check module files for breaking changes' {
    $ModuleRoot = "$PSScriptRoot\..\..\Vester"
    $PublicFiles = Get-ChildItem "$ModuleRoot\Public"

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
            $manifest.Version -as [Version] | Should BeGreaterThan '1.1.0'
            $manifest.Guid | Should BeExactly 'cd038486-b669-4edb-a66d-bfe94c61b011'
            $manifest.Author | Should BeExactly 'Chris Wahl'
            $manifest.CompanyName | Should BeExactly 'Community'
            $manifest.Copyright | Should BeExactly 'Apache License'
            $manifest.Description | Should BeOfType String
            $manifest.PowerShellVersion | Should Be '3.0'
            $manifest.RequiredModules.Name | Should BeExactly @('Pester','VMware.VimAutomation.Core')
            $manifest.RequiredModules.Version | Should BeExactly @('3.4.3','6.5.1')
            $manifest.ExportedFunctions.Values.Name | Should BeExactly $PublicFiles.BaseName

            $manifest.PrivateData.PSData.Tags | Should BeExactly @('vester','vmware','vcenter','vsphere','esxi','powercli')
            $manifest.PrivateData.PSData.LicenseUri | Should BeExactly 'https://github.com/WahlNetwork/Vester/blob/master/LICENSE'
            $manifest.PrivateData.PSData.ProjectUri | Should BeExactly 'https://github.com/WahlNetwork/Vester'
            $manifest.PrivateData.PSData.ReleaseNotes | Should Match "## \[$($manifest.Version)\] -"
        }

        $VesterCommands = (Get-Command -Module Vester).Name

        It 'Exports expected functions' {
            $PublicFiles.BaseName | Should BeExactly $VesterCommands
        }

        It 'Contains tests for each public function' {
            # Get all files in the .\Tests\Function folder, then drop the ".Tests" and compare to exported commands
            $FunctionTests = (Get-ChildItem "$PSScriptRoot\..\Function").BaseName -replace '\..*',''
            $FunctionTests | Should BeExactly $VesterCommands
        }
    }

    # InModuleScope helps test private functions
    InModuleScope Vester {
        # Run unit tests for all private functions here
        # Instead of breaking out into individual files like the public functions
        Context 'Contains expected private functions' {
            It 'Read-HostColor behaves normally' {
                Mock Write-Host -Verifiable
                Mock Read-Host  -Verifiable -MockWith {return 'rh-Test'}

                Read-HostColor | Should BeExactly 'rh-Test'

                # Ensure that Write-Host & Read-Host were actually called within Read-HostColor
                Assert-VerifiableMocks
            }

            # (Any additional private functions as It tests here)
        } #Context private
    } #InModuleScope
} #Describe
