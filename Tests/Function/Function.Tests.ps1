$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get information from the module manifest
$manifestPath = "$here\..\..\Vester\Vester.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a Vester module is already loaded
$Module = Get-Module -Name 'Vester' -ErrorAction SilentlyContinue

#Load the module if needed (not already loaded or not the good version)
If ($Module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        $Module = Import-Module "$here\..\..\Vester" -Version $manifest.version -force
    }
} else {
    $Module = Import-Module "$here\..\..\Vester" -Version $manifest.version -force
}

# Load the datas
. $here\Function.Data.ps1


# Pester tests
Describe "No public function left behind" {

    $Module.ExportedFunctions.GetEnumerator() | ForEach-Object {
        $Name = $_.Value.Name

        It "Function $Name is tested" {
            $data.values.name -contains $Name | Should Be $True
        }
    }
}

Describe "Functions Parameters" {

    $Data.GetEnumerator() | ForEach-Object {

        $Name = $_.Value.Name
        $Params = $_.Value.Parameters

        Context "$Name" {
            $Command = Get-Command -Name $Name

            Foreach ($Param in $Params) {

                It "Function $($command.Name) contains Parameter $($Param['Name'])" {
                    $Command.Parameters.Keys -contains $Param['Name'] | Should Be $True
                }

                It "Parameter $($Param['Name']) type is $($Param['type'])" {
                    $Command.Parameters.($Param['Name']).ParameterType.Name -eq $Param['Type'] | Should Be $True
                }

                It "Parameter $($Param['Name']) Mandatory value is $($Param['mandatory'])" {
                    $Command.Parameters.($Param['Name']).Attributes.Mandatory | Should Be $Param['mandatory']
                }

                It "Parameter $($Param['Name']) ValueFromPipeline value is $($Param['ValueFromPipeline'])" {
                    $Command.Parameters.($Param['Name']).Attributes.ValueFromPipeline | Should Be $Param['ValueFromPipeline']
                }

                It "Parameter $($Param['Name']) ValueFromPipeline value is $($Param['ValueFromPipelineByPropertyName'])" {
                    $Command.Parameters.($Param['Name']).Attributes.ValueFromPipelineByPropertyName | Should Be $Param['ValueFromPipelineByPropertyName']
                }

                If ($Param['Aliases']) {
                    It "Parameter $($Param['Name']) Aliases are $($Param['Aliases'])" {
                        Compare-Object -ReferenceObject $Param['Aliases'] -DifferenceObject $Command.Parameters.($Param['Name']).Aliases | Should BeNullOrEmpty
                    }
                } else {
                    It "Parameter $($Param['Name']) has no aliase" {
                        $Command.Parameters.($Param['Name']).Aliases | Should BeNullOrEmpty
                    }                      
                }                 
            }
        }
    }
}
