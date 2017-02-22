#Requires -Version 3 -Modules Pester

Describe 'New-VesterConfig unit tests' -Tag 'unit' {
    # Manually define & load the file/function for testing
    $File = (Get-Item "$PSScriptRoot\..\..\Vester\Public\New-VesterConfig.ps1").FullName
    . $File

    # Mocks

    
    Context 'Structure' {
        # Hard-coded parameter names here
        # By design, this array requires updating if function params change
        $Parameters = @('OutputFolder','Quiet')

        $Command = Get-Command New-VesterConfig
        $Help = Get-Help New-VesterConfig

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

        It 'Confirms parameter sets have not changed' {
            $Command.ParameterSets.Count | Should Be 1
        }

        Context 'Parameters match expected values' {
            # One It block here for each New-VesterConfig parameter

            It '-OutputFolder matches expected values' {
                $ParamConfig = $Command.Parameters['OutputFolder']
                $HelpConfig = $Help.Parameters.Parameter | Where Name -eq 'OutputFolder'

                $ParamConfig.ParameterType.Name | Should BeExactly 'Object'
                $ParamConfig.Attributes.Mandatory | Should Be $false
                $ParamConfig.Attributes.ValueFromPipeline | Should Be $false
                $ParamConfig.Attributes.ValueFromPipelineByPropertyName | Should Be $false
                $ParamConfig.Attributes.Position | Should Be 0
                $ParamConfig.Aliases | Should BeNullOrEmpty
                $HelpConfig.defaultValue | Should BeExactly '"$(Split-Path -Parent $PSScriptRoot)\Configs"'
            }

            It '-Quiet matches expected values' {
                $ParamConfig = $Command.Parameters['Quiet']
                $HelpConfig = $Help.Parameters.Parameter | Where Name -eq 'Quiet'

                $ParamConfig.ParameterType.Name | Should BeExactly 'SwitchParameter'
                $ParamConfig.Attributes.Mandatory | Should Be $false
                $ParamConfig.Attributes.ValueFromPipeline | Should Be $false
                $ParamConfig.Attributes.ValueFromPipelineByPropertyName | Should Be $false
                $ParamConfig.Aliases | Should BeNullOrEmpty
                $HelpConfig.defaultValue | Should Be $false
            }
        } #context parameters match expected
    } #context structure

    <# 
        Too many different, hard-coded PowerCLI commands right now
        Not worth the effort to do any further testing until New-VesterConfig refactoring

    Context 'Input' {

    } #context input

    Context 'Execution' {

    } #context execution

    Context 'Output' {

    } #context output

    #>

} #describe
