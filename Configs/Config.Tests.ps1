#requires -Version 3 -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding()]
Param(
    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = "$PSScriptRoot\Config.ps1"
)

Process {
    Describe 'Config file validation' {
        It 'Is reading a valid config file' {
            $Config | Should Exist
        }
        
        # Ensure $config is loaded into the session
        . $Config

        It 'Properly supplies variable $config' {
            $config | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .vcenter' {
            $config.vcenter.Keys | Should Match 'vc|smtpsender|smtpport|smtpserver|EventMaxAge|EventMaxAgeEnabled|TaskMaxAge|TaskMaxAgeEnabled'
            $config.vcenter.Keys.Count | Should Be 8
            $config.vcenter.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.vcenter.smtpsender | Should BeOfType String
            $config.vcenter.smtpport | Should BeOfType Int
            $config.vcenter.smtpserver | Should BeOfType String
            $config.vcenter.EventMaxAge | Should BeOfType Int
            $config.vcenter.EventMaxAgeEnabled | Should BeOfType Bool
            $config.vcenter.TaskMaxAge | Should BeOfType Int
            $config.vcenter.TaskMaxAgeEnabled  | Should BeOfType Bool
            # Connect, unless a connection that matches the .vc definition is found
            If ($DefaultVIServer.Name -ne $config.vcenter.vc) {
                # Optionally, un-comment the next line to ignore certificate warnings in the current session
                # Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -Confirm:$false | Out-Null
                Connect-VIServer $config.vcenter.vc | Should Not BeNullOrEmpty
            }
        }

        It 'Contains proper settings for .scope' {
            $config.scope.Keys | Should Match 'cluster|host|vm|vds'
            $config.scope.Keys.Count | Should Be 4
            $config.scope.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            Get-Cluster $config.scope.cluster | Should Not BeNullOrEmpty
            Get-VMHost $config.scope.host | Should Not BeNullOrEmpty
            Get-VM $config.scope.vm | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .cluster' {
            $config.cluster.Keys | Should Match 'drsenabled|drsmode|drslevel|haenable'
            $config.cluster.Keys.Count | Should Be 3
            $config.cluster.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.cluster.drsenabled | Should BeOfType Bool
            $config.cluster.drsmode | Should Match 'FullyAutomated|Manual|PartiallyAutomated'
            $config.cluster.drslevel | Should BeOfType Int
            $config.cluster.drslevel | Should Match '[1-5]'
            $config.cluster.haenable | Should BeOfType Bool
        }

        It 'Contains proper settings for .host' {
            $HostKeys = 'sshenable|sshwarn|esxntp|esxdns|searchdomains|esxsyslog|esxsyslogfirewallexception|sshtimeout|sshinteractivetimeout'
            $config.host.Keys | Should Match $HostKeys
            $config.host.Keys.Count | Should Be 9
            $config.host.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.host.sshenable | Should BeOfType Bool
            $config.host.sshwarn | Should BeOfType Int
            $config.host.sshwarn | Should Match '[0-1]'
            $config.host.esxntp | ForEach-Object {
                (w32tm /stripchart /computer:$_ /dataonly /samples:1)[3] | Should Match '\d{2}\:\d{2}\:\d{2}\,'
            }
            $config.host.esxdns | ForEach-Object {
                Resolve-DnsName -Name 'mit.edu' -Type A -Server $_ | Should Not BeNullOrEmpty
            }
            $config.host.searchdomains | ForEach-Object {
                $_ | Should Not BeNullOrEmpty
            }
            $config.host.esxsyslog | ForEach-Object {
                $_ | Should Not BeNullOrEmpty
            }
            $config.host.esxsyslogfirewallexception | Should BeOfType Bool
            $config.host.sshtimeout | Should BeOfType Int
            $config.host.sshinteractivetimeout | Should BeOfType Int
        }

        It 'Contains proper settings for .vm' {
            $VMKeys = 'snapretention|allowconnectedcdrom|allowcpulimit|allowmemorylimit|syncTimeWithHost|bootDelay'
            $config.vm.Keys | Should Match $VMKeys
            $config.vm.Keys.Count | Should Be 6
            $config.vm.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.vm.snapretention | Should BeOfType Int
            $config.vm.snapretention | Should BeGreaterThan -1
            $config.vm.allowconnectedcdrom | Should BeOfType Bool
            $config.vm.allowcpulimit | Should BeOfType Bool
            $config.vm.allowmemorylimit | Should BeOfType Bool
            $config.vm.syncTimeWithHost | Should BeOfType Bool
            $config.vm.bootDelay | Should BeOfType Int
        }

        It 'Contains proper settings for .nfs' {
            $NFSKeys = 'NFS\.HeartbeatFrequency|NFS\.DeleteRPCTimeout|NFS\.MaxQueueDepth|Net\.TcpipHeapSize|Net\.TcpipHeapMax|NFS\.MaxVolumes'
            $config.nfsadvconfig.Keys | Should Match $NFSKeys
            $config.nfsadvconfig.Keys.Count | Should Be 6
            $config.nfsadvconfig.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $NFSKeys -replace '\\','' -split '\|' | ForEach-Object {
                $config.nfsadvconfig.$_ | Should BeOfType Int
            }
        }

        It 'Contains proper settings for .vds' {
            $VDSKeys = 'linkproto|linkoperation|mtu'
            $config.vds.Keys | Should Match $VDSKeys
            $config.vds.Keys.Count | Should Be 3
            $config.vds.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.vds.linkproto | Should BeOfType String
            $config.vds.linkproto | Should Match 'LLDP|CDP'
            $config.vds.linkoperation | Should BeOfType String
            $config.vds.linkoperation | Should Match 'Listen|Advertise|Both|Disabled'
            $config.vds.mtu | Should BeOfType Int
            $config.vds.mtu | Should Match '[1500-9000]'
        }
    } #Describe
} #Process