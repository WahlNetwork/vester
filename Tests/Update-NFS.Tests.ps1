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
    Describe -Name 'Host Configuration: NFS Advanced Configuration' -Tag @("host","storage","nfs") -Fixture {
        # Variables
        . $Config
        [System.Collections.Hashtable]$nfsadvconfig = $config.nfsadvconfig
        $compare = @()
        $nfsadvconfig.Values | ForEach-Object -Process {
            $compare += $_
        }
        foreach ($server in (Get-VMHost -Name $config.scope.host).name) 
        {
            $hostadvcfg = Get-AdvancedSetting -Entity $server
            $hostadvsettings = @{}
            foreach ($setting in $hostadvcfg) { 
                $sname = $setting.name
                $svalue = $setting.value
                $hostadvsettings[$sname] = $svalue
        }
            $value =@() 
            foreach ($setting in $nfsadvconfig.Keys) {
                if ($hostadvsettings.ContainsKey($setting)){
                    $value += $hostadvsettings.$setting
                } else { 
                    #nop 
                }
            }
            It -name "$server NFS Settings" -test {
                try 
                {
                    $value | Should Be $compare
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        Write-Warning -Message "Remediating $server"                    
                        $nfsadvconfig.Keys | ForEach-Object -Process {
                            Get-AdvancedSetting -Entity $server -Name $_ | Set-AdvancedSetting -Value $nfsadvconfig.Item($_) -Confirm:$false -ErrorAction Stop
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