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

    Context 'Input' {
        Context 'Parameters match expected values' {
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

        # TODO: Dump a .json config into $TestDrive:

        # TODO: Should intake .json config as expected

        # TODO: Should intake one/many .Vester.ps1 tests

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
