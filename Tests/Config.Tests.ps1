#requires -Version 3 -Modules Pester, VMware.VimAutomation.Core

Get-Module VMware.VimAutomation.Core | Remove-Module -Force
Import-Module VMware.VimAutomation.Core -Force

InModuleScope VMware.VimAutomation.Core {
    # Ensure $config is loaded into the session
    Invoke-Expression -Command (Get-Item -Path "$PSScriptRoot\Config.ps1")

    Describe 'Config file validation' {
        It 'Exists and properly supplies variable $config' {
            "$PSScriptRoot\Config.ps1" | Should Exist
            $config | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .vcenter' {
            $config.vcenter.Keys | Should Be 'vc'
            $config.vcenter.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            # Connect, unless a connection that matches the .vc definition is found
            If ($DefaultVIServer.Name -ne $config.vcenter.vc) {
                # Optionally, un-comment the next line to ignore certificate warnings in the current session
                # Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -Confirm:$false | Out-Null
                Connect-VIServer $config.vcenter.vc | Should Not BeNullOrEmpty
            }
        }

        It 'Contains proper settings for .scope' {
            $config.scope.Keys | Should Match 'cluster|host|vm'
            $config.scope.Keys.Count | Should Be 3
            $config.scope.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            Get-Cluster $config.scope.cluster | Should Not BeNullOrEmpty
            Get-VMHost $config.scope.host | Should Not BeNullOrEmpty
            Get-VM $config.scope.vm | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .cluster' {
            $config.cluster.Keys | Should Match 'drsmode|drslevel'
            $config.cluster.Keys.Count | Should Be 2
            $config.cluster.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.cluster.drsmode | Should Match 'FullyAutomated|Manual|PartiallyAutomated'
            $config.cluster.drslevel | Should BeOfType Int
            $config.cluster.drslevel | Should Match '[1-5]'
        }

        It 'Contains proper settings for .host' {
            $HostKeys = 'sshenable|sshwarn|esxntp|esxdns|searchdomains|esxsyslog'
            $config.host.Keys | Should Match $HostKeys
            $config.host.Keys.Count | Should Be 6
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
        }

        It 'Contains proper settings for .vm' {
            $VMKeys = 'snapretention|allowconnectedcdrom|allowcpulimit|allowmemorylimit'
            $config.vm.Keys | Should Match $VMKeys
            $config.vm.Keys.Count | Should Be 4
            $config.vm.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.vm.snapretention | Should BeOfType Int
            $config.vm.snapretention | Should BeGreaterThan -1
            $config.vm.allowconnectedcdrom | Should BeOfType Bool
            $config.vm.allowcpulimit | Should BeOfType Bool
            $config.vm.allowmemorylimit | Should BeOfType Bool
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
    } #Describe
} #InModuleScope
