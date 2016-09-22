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
    Describe -Name 'Host : Net Dump Settings' -Tags @("host") -Fixture {
        # Variables
        . $Config
        [string]$netDumpEnabled = $config.host.netDumpEnabled
        [string]$netDumpHostVNic = $config.host.netDumpHostVNic
        [string]$netDumpNetworkServerIP = $config.host.netDumpNetworkServerIP
        [int]$netDumpNetworkServerPort = $config.host.netDumpNetworkServerPort
                                
        foreach ($server in (Get-VMHost $config.scope.host)) 
        {
            $value = (Get-EsxCli -v2 -vmhost $server).system.coredump.network.get.invoke()
            It -name "$($server.name) : Host Net Dump Configuration : Enabled" -test {
                try 
                {
                    $value.enabled | Should Be $netDumpEnabled
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        $esxcli = Get-EsxCli -v2 -VMHost $server
                        $arguments = $esxcli.system.coredump.network.set.CreateArgs()
                        $arguments.enable = $netDumpEnabled
                        $esxcli.system.coredump.network.set.Invoke($arguments)
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

            It -name "$($server.name) : Host Net Dump Configuration : Settings" -test {
                try 
                {
                    $value.HostVNic | Should be $netDumpHostVNic
                    $value.NetworkServerIP | Should be $netDumpNetworkServerIP
                    $value.NetworkServerPort | Should be $netDumpNetworkServerPort
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        $esxcli = Get-EsxCli -v2 -VMHost $server
                        $arguments = $esxcli.system.coredump.network.set.CreateArgs()
                        $arguments.interfacename = $netDumpHostVNic
                        $arguments.serveripv4 = $netDumpNetworkServerIP
                        $arguments.serverport = $netDumpNetworkServerPort
                        $esxcli.system.coredump.network.set.Invoke($arguments)
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
