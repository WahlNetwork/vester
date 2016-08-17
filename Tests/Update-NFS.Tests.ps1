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

        foreach ($server in (Get-VMHost -Name $config.scope.host).name) 
        {
            It -name "$server NFS Settings" -test {
                $value = @()
                $nfsadvconfig.Keys | ForEach-Object -Process {
                    $value += (Get-AdvancedSetting -Entity $server -Name $_).Value
                }
                $compare = @()
                $nfsadvconfig.Values | ForEach-Object -Process {
                    $compare += $_
                }
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