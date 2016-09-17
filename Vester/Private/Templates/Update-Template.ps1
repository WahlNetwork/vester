#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    ###Describe -Name '!!! Configuration: !!!' -Fixture {
    # Variables
    . $Config
    ###[type]$var1 = $config.!!!
    ###[type]$var2 = $config.!!!

    foreach ($server in (Get-VMHost -Name $config.scope.host)) 
    {
        ###It -name '!!!' -test {
            ###$value = !!!TestMe
            try 
            {
                ###$value | Should Be !!!SomethingElse
            }
            catch 
            {
                if ($Remediate) 
                {
                    Write-Warning -Message $_
                    ###Write-Warning -Message "Remediating !!!" 
                }
                else 
                {
                    throw $_
                }
            }
        }
    }
}
