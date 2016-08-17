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
    Describe -Name 'Host Configuration: NTP Server(s)' -Tags @("host") -Fixture {
        # Variables
        . $Config
        [array]$esxntp = $config.host.esxntp

        foreach ($server in (Get-VMHost $config.scope.host)) 
        {
            It -name "$($server.name) Host NTP settings" -test {
                $value = Get-VMHostNtpServer -VMHost $server
                try 
                {
                    Compare-Object -ReferenceObject $esxntp -DifferenceObject $value | Should Be $null
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"
                        Get-VMHostNtpServer -VMHost $server | ForEach-Object -Process {
                            Remove-VMHostNtpServer -VMHost $server -NtpServer $_ -Confirm:$false -ErrorAction Stop
                        }
                        Add-VMHostNtpServer -VMHost $server -NtpServer $esxntp -ErrorAction Stop
                        $ntpclient = Get-VMHostService -VMHost $server | Where-Object -FilterScript {
                            $_.Key -match 'ntpd'
                        }
                        $ntpclient | Set-VMHostService -Policy:On -Confirm:$false -ErrorAction:Stop
                        $ntpclient | Restart-VMHostService -Confirm:$false -ErrorAction:Stop
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
