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
    Describe -Name 'Host Configuration: Syslog Server' -Tags @("host") -Fixture {
        # Variables
        . $Config
        [array]$esxsyslog = $config.host.esxsyslog

        foreach ($server in (Get-VMHost -Name $config.scope.host)) 
        {
            It -name "$($server.name) Host Syslog Service State" -test {
                [array]$value = Get-VMHostSysLogServer -VMHost $server
                try 
                {
                    Compare-Object -ReferenceObject $esxsyslog -DifferenceObject $value | Should Be $null
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        Set-VMHostSysLogServer -VMHost $server -SysLogServer $esxsyslog -ErrorAction Stop
                        (Get-EsxCli -VMHost $server).system.syslog.reload()
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
        }
    }
}
