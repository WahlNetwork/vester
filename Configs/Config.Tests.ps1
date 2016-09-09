#requires -Version 3 -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding()]
Param(
    # This test doesn't remediate, but Invoke-Vester needs to supply the parameter
    [switch]$Remediate = $false,

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

        It 'Properly supplies variable $cfg' {
            $cfg | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .vcenter' {
            $cfg.vcenter.Keys | Should Be 'vc'
            $cfg.vcenter.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            # Connect, unless a connection that matches the .vc definition is found
            If ($DefaultVIServer.Name -ne $cfg.vcenter.vc) {
                # Optionally, un-comment the next line to ignore certificate warnings in the current session
                # Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -Confirm:$false | Out-Null
                Connect-VIServer $cfg.vcenter.vc | Should Not BeNullOrEmpty
            }
        }

        It 'Contains proper settings for .scope' {
            $cfg.scope.Keys | Should Match 'cluster|host|vm|vds'
            $cfg.scope.Keys.Count | Should Be 4
            $cfg.scope.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            Get-Cluster $cfg.scope.cluster | Should Not BeNullOrEmpty
            Get-VMHost $cfg.scope.host | Should Not BeNullOrEmpty
            Get-VM $cfg.scope.vm | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .cluster' {
            $cfg.cluster.Keys | Should Match 'drsmode|drslevel'
            $cfg.cluster.Keys.Count | Should Be 2
            $cfg.cluster.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $cfg.cluster.drsmode | Should Match 'FullyAutomated|Manual|PartiallyAutomated'
            $cfg.cluster.drslevel | Should BeOfType Int
            $cfg.cluster.drslevel | Should Match '[1-5]'
        }

        It 'Contains proper settings for .host' {
            $HostKeys = 'sshenable|sshwarn|esxntp|esxdns|searchdomains|esxsyslog'
            $cfg.host.Keys | Should Match $HostKeys
            $cfg.host.Keys.Count | Should Be 6
            $cfg.host.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $cfg.host.sshenable | Should BeOfType Bool
            $cfg.host.sshwarn | Should BeOfType Int
            $cfg.host.sshwarn | Should Match '[0-1]'
            $cfg.host.esxntp | ForEach-Object {
                (w32tm /stripchart /computer:$_ /dataonly /samples:1)[3] | Should Match '\d{2}\:\d{2}\:\d{2}\,'
            }
            $cfg.host.esxdns | ForEach-Object {
                Resolve-DnsName -Name 'mit.edu' -Type A -Server $_ | Should Not BeNullOrEmpty
            }
            $cfg.host.searchdomains | ForEach-Object {
                $_ | Should Not BeNullOrEmpty
            }
            $cfg.host.esxsyslog | ForEach-Object {
                $_ | Should Not BeNullOrEmpty
            }
        }

        It 'Contains proper settings for .vm' {
            $VMKeys = 'snapretention|allowconnectedcdrom|allowcpulimit|allowmemorylimit'
            $cfg.vm.Keys | Should Match $VMKeys
            $cfg.vm.Keys.Count | Should Be 4
            $cfg.vm.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $cfg.vm.snapretention | Should BeOfType Int
            $cfg.vm.snapretention | Should BeGreaterThan -1
            $cfg.vm.allowconnectedcdrom | Should BeOfType Bool
            $cfg.vm.allowcpulimit | Should BeOfType Bool
            $cfg.vm.allowmemorylimit | Should BeOfType Bool
        }

        It 'Contains proper settings for .nfs' {
            $NFSKeys = 'NFS\.HeartbeatFrequency|NFS\.DeleteRPCTimeout|NFS\.MaxQueueDepth|Net\.TcpipHeapSize|Net\.TcpipHeapMax|NFS\.MaxVolumes'
            $cfg.nfsadvconfig.Keys | Should Match $NFSKeys
            $cfg.nfsadvconfig.Keys.Count | Should Be 6
            $cfg.nfsadvconfig.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $NFSKeys -replace '\\','' -split '\|' | ForEach-Object {
                $cfg.nfsadvconfig.$_ | Should BeOfType Int
            }
        }

        It 'Contains proper settings for .vds' {
            $VDSKeys = 'linkproto|linkoperation|mtu'
            $cfg.vds.Keys | Should Match $VDSKeys
            $cfg.vds.Keys.Count | Should Be 3
            $cfg.vds.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $cfg.vds.linkproto | Should BeOfType String
            $cfg.vds.linkproto | Should Match 'LLDP|CDP'
            $cfg.vds.linkoperation | Should BeOfType String
            $cfg.vds.linkoperation | Should Match 'Listen|Advertise|Both|Disabled'
            $cfg.vds.mtu | Should BeOfType Int
            $cfg.vds.mtu | Should Match '[1500-9000]'
        }
    } #Describe
} #Process
