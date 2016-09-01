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
        # Variables
        . $Config
        [string]$SMTPSender = $config.vcenter.smtpsender
        [int]$SMTPPort = $config.vcenter.smtpport
        [string]$SMTPServer = $config.vcenter.smtpserver

        foreach ($VCServer in ($Global:DefaultVIServers)) 
        {
            It -name "$($VCServer.name) SMTP Sender" -test {
                try 
                {
                    $value | Should Be $SMTPSender
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating SMTP Sender on $($VCServer.name)"
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }


            It -name "$($VCServer.name) SMTP Port" -test {
                try 
                {
                    $value | Should Be $SMTPPort
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating SMTP Port on $($VCServer.name)"
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

            
            It -name "$($VCServer.name) SMTP Server" -test {
                try 
                {
                    $value | Should Be $SMTPServer
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating SMTP Server on $($VCServer.name)"
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }

        }#End Foreach
    }
}
