#requires -Modules Pester
#requires -Modules VMware.VimAutomation.Core


[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Remediation toggle')]
    [ValidateNotNullorEmpty()]
    [switch]$Remediate,
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Path to the configuration file')]
    [ValidateNotNullorEmpty()]
    [string]$Config
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
