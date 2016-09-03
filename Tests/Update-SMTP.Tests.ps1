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
    Describe -Name 'vCenter Configuration: SMTP Settings' -Tags @("vcenter","SMTP") -Fixture {
        # Variables
        . $Config
        [string]$SMTPSender = $config.vcenter.smtpsender
        [int]$SMTPPort = $config.vcenter.smtpport
        [string]$SMTPServer = $config.vcenter.smtpserver

        foreach ($VCServer in ($config.vcenter.vc)) 
        {
        $VCMailSettings = Get-AdvancedSetting -Entity $VCServer -Name @('mail*')

            It -name "$($VCServer) SMTP Sender" -test {
                $value = $VCMailSettings[0].value
                try 
                {
                    $value | Should Be $SMTPSender
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating SMTP Sender on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name mail.sender | Set-AdvancedSetting -value $SMTPSender -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }


            It -name "$($VCServer) SMTP Port" -test {
                $value = $VCMailSettings[2].value
                try 
                {
                    $value | Should Be $SMTPPort
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating SMTP Port on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name mail.smtp.port | Set-AdvancedSetting -value $SMTPPort -Confirm:$false -ErrorAction Stop
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

            
            It -name "$($VCServer) SMTP Server" -test {
                $value = $VCMailSettings[3].value
                try 
                {
                    $value | Should Be $SMTPServer
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating SMTP Server on $($VCServer)"
                        Get-AdvancedSetting -Entity $VCServer -Name mail.smtp.server | Set-AdvancedSetting -value $SMTPServer -Confirm:$false -ErrorAction Stop
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
