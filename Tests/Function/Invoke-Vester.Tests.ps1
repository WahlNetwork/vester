#Requires -Version 3 -Modules Pester

Describe -Name 'Invoke-Vester unit tests' -Tag 'unit' {
    # TODO: Upon completion, rearrange Context/It as desired

    # Hard-coded parameter names here
    # By design, this array requires updating if function params change
    $Parameters = @('Config','Test','Remediate','XMLOutputFile')

    # Manually define & load the file/function for testing
    $File = (Get-Item "$PSScriptRoot\..\..\Vester\Public\Invoke-Vester.ps1").FullName
    . $File

    $Command = Get-Command Invoke-Vester
    $Help = Get-Help Invoke-Vester

    It 'Exports the function successfully' {
        $Command | Should Not BeNullOrEmpty
    }

    It 'Should be an advanced function' {
        # Create dummy function with advanced function parameters for comparison
        function DummyFunction {
            [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
            param ()
        }

        # DummyFunction has all common parameters, including extras WhatIf & Confirm
        # What is left over should be exactly what we defined up top
        $Command.Parameters.Keys |
            Where {$_ -notin (Get-Command DummyFunction).Parameters.Keys} |
            Should Be $Parameters
    }

    # TODO: make this pretty
    It 'parameter sets' {
        $Command.ParameterSets.Count | Should Be 1
    }

    # Create barebones config.json files
    @{vcenter = @{vc = 'vCenterServer1'}} |
        ConvertTo-Json | Out-File "TestDrive:\config1.json"
    @{vcenter = @{vc = 'vCenterServer2'}} |
        ConvertTo-Json | Out-File "TestDrive:\config2.json"
    $json = @("TestDrive:\config1.json", "TestDrive:\config2.json")

    # Mocks
    Mock Connect-VIServer {'asdf'}
    Mock Invoke-Pester -MockWith {'xml'} -ParameterFilter {
        $OutputFormat -eq 'NUnitXml' -and $OutputFile
    }
    Mock Invoke-Pester {'pester'}

    Context 'Input' {
        Context 'Parameters match expected values' {
            # One It block here for each Invoke-Vester parameter

            It '-Config matches expected values' {
                $ParamConfig = $Command.Parameters['Config']
                $HelpConfig = $Help.Parameters.Parameter | Where Name -eq 'Config'

                $ParamConfig.ParameterType.Name | Should BeExactly 'Object[]'
                $ParamConfig.Attributes.Mandatory | Should Be $false
                $ParamConfig.Attributes.ValueFromPipeline | Should Be $true
                $ParamConfig.Attributes.ValueFromPipelineByPropertyName | Should Be $true
                $ParamConfig.Attributes.Position | Should Be 0
                $ParamConfig.Aliases | Should BeExactly 'FullName'
                $HelpConfig.defaultValue | Should BeExactly '"$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json"'
            }

            It '-Test matches expected values' {
                $ParamConfig = $Command.Parameters['Test']
                $HelpConfig = $Help.Parameters.Parameter | Where Name -eq 'Test'

                $ParamConfig.ParameterType.Name | Should BeExactly 'Object[]'
                $ParamConfig.Attributes.Mandatory | Should Be $false
                $ParamConfig.Attributes.ValueFromPipeline | Should Be $false
                $ParamConfig.Attributes.ValueFromPipelineByPropertyName | Should Be $false
                $ParamConfig.Attributes.Position | Should Be 1
                $ParamConfig.Aliases | Should BeExactly @('Path','Script')
                $HelpConfig.defaultValue | Should BeExactly '"$(Split-Path -Parent $PSScriptRoot)\Tests\"'
            }

            It '-Remediate matches expected values' {
                $ParamConfig = $Command.Parameters['Remediate']
                $HelpConfig = $Help.Parameters.Parameter | Where Name -eq 'Remediate'

                $ParamConfig.ParameterType.Name | Should BeExactly 'SwitchParameter'
                $ParamConfig.Attributes.Mandatory | Should Be $false
                $ParamConfig.Attributes.ValueFromPipeline | Should Be $false
                $ParamConfig.Attributes.ValueFromPipelineByPropertyName | Should Be $false
                $ParamConfig.Aliases | Should BeNullOrEmpty
                $HelpConfig.defaultValue | Should Be $false
            }

            It '-XMLOutputFile matches expected values' {
                $ParamConfig = $Command.Parameters['XMLOutputFile']
                $HelpConfig = $Help.Parameters.Parameter | Where Name -eq 'XMLOutputFile'

                $ParamConfig.ParameterType.Name | Should BeExactly 'Object'
                $ParamConfig.Attributes.Mandatory | Should Be $false
                $ParamConfig.Attributes.ValueFromPipeline | Should Be $false
                $ParamConfig.Attributes.ValueFromPipelineByPropertyName | Should Be $false
                $ParamConfig.Attributes.Position | Should Be 2
                $ParamConfig.Aliases | Should BeNullOrEmpty
                $HelpConfig.defaultValue | Should BeNullOrEmpty
            }
        } #context parameters match expected

        Context 'Config .json input is handled properly' {
            # TODO: Extensive mocking here (or further up the line?)

            It 'Accepts one .json config file' {
                {Invoke-Vester -Config $json[0]} | Should Not Throw
                # Should accept in position 0
                {Invoke-Vester $json[0]} | Should Not Throw
                # Should accept piped input by value
                {$json[0] | Invoke-Vester} | Should Not Throw
                # Should accept piped input by property name (FullName)
                {Get-Item $json[0] | Invoke-Vester} | Should Not Throw

                # TODO: Needs tests that should fail
            }

            It 'Accepts multiple .json config files' {
                {Invoke-Vester -Config $json} | Should Not Throw
                # Should accept in position 0
                {Invoke-Vester $json} | Should Not Throw
                # Should accept piped input by value
                {$json | Invoke-Vester} | Should Not Throw
                # Should accept piped input by property name (FullName)
                {Get-ChildItem TestDrive:\ | Invoke-Vester} | Should Not Throw
                # One by value, one by property name
                {@('TestDrive:\config1.json', (Get-Item $json[1])) | Invoke-Vester} | Should Not Throw

                # TODO: Needs tests that should fail
            }
        } #context json


        # TODO: Should intake one/many .Vester.ps1 tests
        Context 'Tests .Vester.ps1 input is handled properly' {
            It 'Accepts one .Vester.ps1 test file' {
                <#
                Invoke-Vester -Config $json[0] -Test
                # Parameter aliases
                Invoke-Vester -Config $json[0] -Path
                Invoke-Vester -Config $json[0] -Script
                #>
            }

            It 'Accepts multiple .Vester.ps1 test files' {

            }

            It 'Accepts a directory' {

            }

            It 'Accepts multiple directories' {

            }
        }

        # TODO: Accepts -Remediate
    } #context input

    Context 'Execution' {
        # TODO: Mocking of internal commands:
            # Get-ChildItem/Get-Item/Split-Path? or above in Input?
            # Connect-VIServer
            # Invoke-Pester

        # TODO: anything else here?
    }

    Context 'Output' {
        # TODO: Passes expected inputs toward VesterTemplate.Tests.ps1

        It "Optionally exports tests via Pester's NUnit XML implementation" {
            # TODO: this
        }
    }
    
    
    
    
}
