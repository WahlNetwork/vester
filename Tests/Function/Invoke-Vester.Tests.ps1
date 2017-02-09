#Requires -Version 3 -Modules Pester

Describe -Name 'Invoke-Vester unit tests' -Tag 'unit' {
    # Manually define & load the file/function for testing
    $File = (Get-Item "$PSScriptRoot\..\..\Vester\Public\Invoke-Vester.ps1").FullName
    . $File

    # Mocks
    Mock Connect-VIServer
    Mock Invoke-Pester {'pester'}

    Context 'Structure' {
        # Hard-coded parameter names here
        # By design, this array requires updating if function params change
        $Parameters = @('Config','Test','Remediate','XMLOutputFile')

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

        It 'Confirms parameter sets have not changed' {
            $Command.ParameterSets.Count | Should Be 1
        }

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
    } #context structure

    Context 'Input' {
        # Create barebones files:
        # .json
        @{vcenter = @{vc = 'vCenterServer1'}} |
            ConvertTo-Json | Out-File 'TestDrive:\config1.json'
        @{vcenter = @{vc = 'vCenterServer2'}} |
            ConvertTo-Json | Out-File 'TestDrive:\config2.json'
        $json = @('TestDrive:\config1.json', 'TestDrive:\config2.json')
        # .Vester.ps1
        New-Item -ItemType File -Path 'TestDrive:\Alpha.Vester.ps1'
        New-Item -ItemType Directory -Path 'TestDrive:\Tests'
        New-Item -ItemType File -Path 'TestDrive:\Tests\Bravo.Vester.ps1'
        $vps1 = @('TestDrive:\Alpha.Vester.ps1', 'TestDrive:\Tests\Bravo.Vester.ps1')
        # And some garbage to purposely fail tests
        'I am not a config file' | Out-File 'TestDrive:\bad.txt'

        Context 'Config .json input is handled properly' {
            # TODO: Extensive mocking here (or further up the line?)

            It 'Accepts one .json config file' {
                Invoke-Vester -Config $json[0] | Should Be 'pester'
                # Should accept in position 0
                Invoke-Vester $json[0] | Should Be 'pester'
                # Should accept piped input by value
                $json[0] | Invoke-Vester | Should Be 'pester'
                # Should accept piped input by property name (FullName)
                Get-Item $json[0] | Invoke-Vester | Should Be 'pester'
            }

            It 'Accepts multiple .json config files' {
                # 2x 'pester' output is expected, because
                # Invoke-Pester is called once for each config file

                Invoke-Vester -Config $json | Should Be @('pester','pester')
                # Should accept in position 0
                Invoke-Vester $json | Should Be @('pester','pester')
                # Should accept piped input by value
                $json | Invoke-Vester | Should Be @('pester','pester')
                # Should accept piped input by property name (FullName)
                Get-ChildItem TestDrive:\*.json | Invoke-Vester |
                    Should Be @('pester','pester')
                # One by value, one by property name
                @('TestDrive:\config1.json', (Get-Item $json[1])) | Invoke-Vester |
                    Should Be @('pester','pester')
            }

            It 'Rejects bad config files' {
                # Not a .json file; should fail
                {'TestDrive:\bad.txt' | Invoke-Vester} | Should -Throw
                # First file is good, but second should error out
                {'TestDrive:\config1.json'; 'TestDrive:\bad.txt' | Invoke-Vester} |
                    Should -Throw
            }
        } #context json


        # TODO: Should intake one/many .Vester.ps1 tests
        Context 'Tests .Vester.ps1 input is handled properly' {

            It 'Accepts one .Vester.ps1 test file' {
                # Specify the exact path
                Invoke-Vester -Config $json[0] -Test $vps1[0] |
                    Should Be 'pester'
                # And a Get-ChildItem that returns one file
                $gci = Get-ChildItem 'TestDrive:\' -Filter '*.Vester.ps1'
                Invoke-Vester -Config $json[0] -Test $gci |
                    Should Be 'pester'
            }

            It 'Accepts multiple .Vester.ps1 test files' {
                # Name them individually
                Invoke-Vester -Config $json[0] -Test $vps1[0],$vps1[1] |
                    Should Be 'pester'
                # Pass an array
                Invoke-Vester -Config $json[0] -Test $vps1 |
                    Should Be 'pester'
                # And a Get-ChildItem that returns two files
                $gci = Get-ChildItem 'TestDrive:\' -Filter '*.Vester.ps1' -Recurse
                Invoke-Vester -Config $json[0] -Test $gci |
                    Should Be 'pester'
            }

            It 'Accepts a directory' {
                Invoke-Vester -Config $json[0] -Test 'TestDrive:\' |
                    Should Be 'pester'
                # And a Get-ChildItem for one (sub)directory
                $gci = Get-ChildItem 'TestDrive:\' -Directory
                Invoke-Vester -Config $json[0] -Test $gci |
                    Should Be 'pester'
            }

            It 'Accepts multiple directories' {
                Invoke-Vester -Config $json[0] -Test 'TestDrive:\','TestDrive:\' |
                    Should Be 'pester'
                # And a Get-ChildItem that returns two directories
                $gci = Get-ChildItem 'TestDrive:\','TestDrive:\' -Directory
                Invoke-Vester -Config $json[0] -Test $gci |
                    Should Be 'pester'
            }

            It 'Rejects made up files and folders' {
                {Invoke-Vester -Config $json[0] -Test 'TestDrive:\nope.Vester.ps1'} |
                    Should -Throw
                {Invoke-Vester -Config $json[0] -Test 'TestDrive:\drivetest\'} |
                    Should -Throw
            }
        }

        Context 'XML input is handled properly' {
            Mock Invoke-Pester -MockWith {'xml'} -ParameterFilter {
                $OutputFormat -eq 'NUnitXml' -and $OutputFile
            }

            # Confirms:
            #   A) Doesn't throw on accepting path on XML param
            #   B) calls Invoke-Pester with the necessary parameters
            It 'Accepts an XML output path' {
                $params = @{
                    Config = $json[0]
                    Test = $vps1[0]
                    XMLOutputFile = 'TestDrive:\vester.xml'
                }
                Invoke-Vester @params | Should Be 'xml'
            }

            It 'Rejects an invalid path' {
                $params = @{
                    Config = $json[0]
                    Test = $vps1[0]
                    XMLOutputFile = 'TestDrive:\zzz\vester.xml'
                }
                {Invoke-Vester @params} | Should -Throw
            }
        }
    } #context input

    # Context Execution:
    # Will be covered via private functions
    # See Vester.Tests.ps1 for unit testing of all private functions

    # Context Output:
    # Doesn't produce any real output, unless using Pester's NUnitXML
    # And we're trusting Pester tests their own XML output :)
    # Our XML intake/conversion is covered in the Context Input block
    
} #describe unit
