#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding(SupportsShouldProcess = $true, 
               ConfirmImpact = 'Medium')]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    Describe -Name 'Host Configuration: NTP Server(s)' -Tags @("host") -Fixture {
        # Variables
        . $Config
        [array]$esxntp = $cfg.host.esxntp

        foreach ($server in (Get-VMHost $cfg.scope.host)) 
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
                        if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - Host '$server'", "Set NTP server(s) to '$esxntp'"))
                        {
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
