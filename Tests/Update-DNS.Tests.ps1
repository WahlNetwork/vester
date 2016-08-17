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
    Describe -Name 'Host Configuration: DNS Server(s)' -Fixture {
        # Variables
        . $Config
        [array]$esxdns = $config.host.esxdns
        [array]$searchdomains = $config.host.searchdomains

        foreach ($server in (Get-VMHost -Name $config.scope.host)) 
        {
            It -name "$($server.name) Host DNS Address" -test {
                [array]$value = (Get-VMHostNetwork -VMHost $server).DnsAddress
                try 
                {
                    Compare-Object -ReferenceObject $esxdns -DifferenceObject $value | Should Be $null
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        Get-VMHostNetwork -VMHost $server | Set-VMHostNetwork -DnsAddress $esxdns -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
            It -name "$($server.name) Host DNS Search Domain" -test {
                [array]$value = (Get-VMHostNetwork -VMHost $server).SearchDomain
                try 
                {
                    Compare-Object -ReferenceObject $searchdomains -DifferenceObject $value | Should Be $null
                }
                catch 
                {
                    if ($fix) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        Get-VMHostNetwork -VMHost $server | Set-VMHostNetwork -SearchDomain $searchdomains -ErrorAction Stop
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