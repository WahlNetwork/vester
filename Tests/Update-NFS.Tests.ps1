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
            $hostadv
            foreach ($setting in $nfsadvconfig.Keys) {
                if ($hostadvsettings.ContainsKey($setting)){
                    $value += $hostadvsetting.$setting
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