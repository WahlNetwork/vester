#requires -Modules VMware.VimAutomation.Core, VMware.VimAutomation.Vds

# TODO: Move to the Private functions folder
function Read-HostColor ($Text) {
    Write-Host $Text -ForegroundColor Yellow -NoNewline
    Write-Output (Read-Host ' ')
}

function New-VesterConfig {
    <#
    TODO: Comment-based help
    #>
    [CmdletBinding()]
    param (
        # Select a folder to create a new Config.json file inside
        [ValidateScript({Test-Path $_})]
        [object]$OutputFolder = (Get-Location).Path,

        # Suppress all prompts and Write-Host. Create the config file with the
        # values of the first Cluster/Host/VM/etc. found.
        [switch]$Quiet

        # TODO: -Quiet not implemented yet
    )

    # Must have only one vCenter connection open
    # Potential future work: loop through all vCenter connections
    If ($DefaultVIServers.Count -lt 1) {
        Write-Warning 'Please connect to vCenter before running this command.'
        throw
    } ElseIf ($DefaultVIServers.Count -gt 1) {
        Write-Warning 'Vester config files are designed to be unique to each vCenter server.'
        Write-Warning 'Please connect to only one vCenter before running this command.'
        Write-Warning "Current connections:  $($DefaultVIServers -join ' / ')"
        throw
    }
    Write-Verbose "vCenter: $($DefaultVIServers.Name)"

    # Introduce and inform of $null
    Write-Host 'Vester will now start pulling values from your vCenter server, ' -ForegroundColor Green -NoNewline
    Write-Host "$($DefaultVIServers.Name)" -ForegroundColor Yellow
    Write-Host 'After each section, you will be asked if you want to edit any values.' -ForegroundColor Green
    Write-Host -ForegroundColor Green 'If there are any values you do not want to test, enter ' -NoNewline
    Write-Host -ForegroundColor Red '$null' -NoNewline
    Write-Host ' to skip those tests.' -ForegroundColor Green

    $config = [ordered]@{}

#region vcenter
    # List properties to check, dump their values into a hashtable
    $vcenterProp = @(
        'mail.sender',
        'mail.smtp.port',
        'mail.smtp.server',
        'event.maxAge',
        'event.maxAgeEnabled',
        'task.maxAge',
        'task.maxAgeEnabled'
    )
    $vcenterHash = @{}
    Get-AdvancedSetting -Entity $DefaultVIServers.Name -Name $vcenterProp | ForEach-Object {
        $vcenterHash.Add($_.Name, $_.Value)
    }

    # Explain each setting
    Write-Host "`n  ### vCenter Settings" -ForegroundColor Green
    Write-Host 'vc                 = [string] vCenter IP Address'
    Write-Host 'smtpsender         = [string] SMTP Address used for emails sent from vCenter Server'
    Write-Host 'smtpport           = [int] Port used to connect to SMTP Server'
    Write-Host 'smtpserver         = [string] SMTP Server used by vCenter to relay emails'
    Write-Host 'EventMaxAge        = [int] Age in days that Events will be retained in the vCenter Server Database'
    Write-Host 'EventMaxAgeEnabled = [bool] Enables Event cleanup and enforces the max age defined in EventMaxAge'
    Write-Host 'TaskMaxAge         = [int] Age in days that Tasks will be retained in the vCenter Server Database'
    Write-Host 'TaskMaxAgeEnabled  = [bool] Enables Task cleanup and enforces the max age defined in TaskMaxAge'
    Write-Host '  ###' -ForegroundColor Green

    # Set the section's config, and then display it for review
    $config.vcenter = [ordered]@{
        vc                 = $DefaultVIServers.Name
        smtpsender         = $vcenterHash['mail.sender']
        smtpport           = $vcenterHash['mail.smtp.port']
        smtpserver         = $vcenterHash['mail.smtp.server']
        EventMaxAge        = $vcenterHash['event.maxAge']
        EventMaxAgeEnabled = $vcenterHash['event.maxAgeEnabled']
        TaskMaxAge         = $vcenterHash['task.maxAge']
        TaskMaxAgeEnabled  = $vcenterHash['task.maxAgeEnabled']
    }
    $config.vcenter

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

#region scope
    # Explain each setting
    Write-Host "`n  ### Scope Settings" -ForegroundColor Green
    Write-Host "This dictates the scope of your vSphere environment that will be tested by Pester."
    Write-Host "Use string values. Wildcards are accepted."
    Write-Host "datacenter = [string] vSphere datacenter name(s)"
    Write-Host "cluster    = [string] vSphere cluster name(s)"
    Write-Host "host       = [string] ESXi host name(s)"
    Write-Host "vm         = [string] Virtual machine name(s)"
    Write-Host "vds        = [string] vSphere Distributed Switch (VDS) name(s)"
    Write-Host '  ###' -ForegroundColor Green

    # Set the section's config, and then display it for review
    $config.scope = [ordered]@{
        datacenter = '*'
        cluster    = '*'
        host       = '*'
        vm         = '*'
        vds        = '*'
    }
    # Empty Write-Host just to insert extra line breaks where desired
    Write-Host ''
    $config.scope

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

#region cluster
    $clusterList = Get-Datacenter -Name $config.scope.datacenter | Get-Cluster -Name $config.scope.cluster

    If ($clusterList.Count -gt 1) {
        Write-Host ''

        # List clusters to choose from
        for ($i = 1; $i -le $clusterList.Count; $i++) {
            Write-Host "$i. " -ForegroundColor Green -NoNewline
            Write-Host "$($clusterList.Name[$i-1])"
        }

        # Pick a cluster (repeat until valid input)
        while (1..$clusterList.Count -notcontains $clusterSelection) {
            $clusterSelection = [int](Read-HostColor "`n-- Select the number of the host to pull values from")
        }
        $cluster = $clusterList[$clusterSelection - 1]
    } ElseIf ($clusterList.Count -eq 1) {
        # If only one cluster, skip the manual prompt
        $cluster = $clusterList
    } ElseIf ($clusterList.Count -eq 1) {
        # If only one cluster, skip the manual prompt
        $cluster = $clusterList
    } Else {
        $noCluster = $true

        # No cluster found; $null the values to skip cluster tests
        $config.cluster = [ordered]@{
            drsmode  = $null
            drslevel = $null
            haenable = $null
        }
    }

    # Explain each setting
    Write-Host "`n  ### Cluster Settings" -ForegroundColor Green
    Write-Host 'drsmode  = [string] FullyAutomated, Manual, or PartiallyAutomated'
    Write-Host 'drslevel = [int] 1 (Aggressive), 2, 3, 4, 5 (Conservative)'
    Write-Host 'haenable = [bool] $true or $false'
    Write-Host '  ###' -ForegroundColor Green

    # Skip this block if there are no clusters
    If ($noCluster -ne $true) {
        # Set the section's config, and then display it for review
        $config.cluster = [ordered]@{
            drsmode  = $cluster.DrsAutomationLevel
            drslevel = ($cluster | Get-View).Configuration.DrsConfig.VmotionRate
            haenable = $cluster.HAEnabled
        }
    }
    Write-Host ''
    $config.cluster

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

#region host
    $hostList = $clusterList | Get-VMHost -Name $config.scope.host | Sort Name

    If ($hostList.Count -gt 1) {
        Write-Host ''

        # List hosts to choose from
        for ($i = 1; $i -le $hostList.Count; $i++) {
            Write-Host "$i. " -ForegroundColor Green -NoNewline
            Write-Host "$($hostList.Name[$i-1])"
        }

        # Pick a host (repeat until valid input)
        while (1..$hostList.Count -notcontains $hostSelection) {
            $hostSelection = [int](Read-HostColor "`n-- Select the number of the host to pull values from")
        }
        $esxi = $hostList[$hostSelection - 1]
    } ElseIf ($hostList.Count -eq 1) {
        # If only one host, skip the manual prompt
        $esxi = $hostList
    } Else {
        # TODO: Got lazy here
        Write-Warning 'No hosts found'
    }

    $hostHash = @{}
    $hostProp = @(
        'mail.sender',
        'mail.smtp.port',
        'mail.smtp.server',
        'event.maxAge',
        'event.maxAgeEnabled',
        'task.maxAge',
        'task.maxAgeEnabled'
    )
    Get-AdvancedSetting -Entity $DefaultVIServers.Name -Name $hostProp | ForEach-Object {
        $hostHash.Add($_.Name,$_.Value)
    }

    # Explain each setting
    Write-Host "`n  ### ESXi Host Settings" -ForegroundColor Green
    Write-Host 'sshenable     = [bool] $true or $false'
    Write-Host 'sshwarn       = [int] 1 (off) or 0 (on)'
    Write-Host 'esxntp        = [array] @("NTP Server 1", "NTP Server 2 (optional)", "NTP Server 3 (optional)", "NTP Server 4 (optional)")'
    Write-Host 'esxdns        = [array] @("DNS Server 1", "DNS Server 2 (optional)")'
    Write-Host 'searchdomains = [array] @("Domain 1", "Domain 2 (optional)")'
    Write-Host 'esxsyslog     = [array] @("tcp://ip_address:port")'
    Write-Host 'esxsyslogfirewallexception = [bool] $true or $false'
    Write-Host '  ###' -ForegroundColor Green

    # Set the section's config, and then display it for review
    $config.host = [ordered]@{
        sshenable                  = ($esxi | Get-VMHostService | Where Key -eq 'TSM-SSH').Running
        sshwarn                    = (Get-AdvancedSetting -Entity $esxi | Where Name -eq 'UserVars.SuppressShellWarning').Value
        esxntp                     = Get-VMHostNtpServer -VMHost $esxi
        esxdns                     = (Get-VMHostNetwork -VMHost $esxi).DnsAddress
        searchdomains              = (Get-VMHostNetwork -VMHost $esxi).SearchDomain
        esxsyslog                  = Get-VMHostSysLogServer -VMHost $esxi
        esxsyslogfirewallexception = ($esxi | Get-VMHostFirewallException -Name syslog).Enabled
        sshtimeout                 = (Get-AdvancedSetting -Entity $esxi | Where Name -eq 'UserVars.ESXIShellTimeout').Value
        sshinteractivetimeout      = (Get-AdvancedSetting -Entity $esxi | Where Name -eq 'UserVars.ESXIShellInteractiveTimeout').Value
    }
    Write-Host ''
    $config.host

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

#region vm
    $vmList = $clusterList | Get-VM -Name $config.scope.vm | Sort Name

    If ($vmList.Count -gt 1) {
        Write-Host ''

        # List VMs to choose from
        for ($i = 1; $i -le $vmList.Count; $i++) {
            Write-Host "$i. " -ForegroundColor Green -NoNewline
            Write-Host "$($vmList.Name[$i-1])"
        }

        # Pick a VM (repeat until valid input)
        while (1..$vmList.Count -notcontains $vmSelection) {
            $vmSelection = [int](Read-HostColor "`n-- Select the number of the VM to pull values from")
        }
        $vm = $vmList[$vmSelection - 1]
    } ElseIf ($vmList.Count -eq 1) {
        # If only one VM, skip the manual prompt
        $vm = $vmList
    } Else {
        # TODO: Got lazy here
        Write-Warning 'No VMs found'
    }

    # Explain each setting
    Write-Host "`n  ### VM Settings" -ForegroundColor Green
    Write-Host 'snapretention       = [int] Allowed number of days for a VM snapshot to exist'
    Write-Host 'allowconnectedcdrom = [bool] $true or $false'
    Write-Host 'allowcpulimit       = [bool] $true or $false'
    Write-Host 'allowmemorylimit    = [bool] $true or $false'
    Write-Host 'bootdelay           = [int] Time in milliseconds'
    Write-Host '  ###' -ForegroundColor Green

    # Set the section's config, and then display it for review
    $config.vm = [ordered]@{
        snapretention       = &{If (($vm | Get-Snapshot) -eq $null) {1} Else {<# TODO: New-Timespan here by counting snapshot age #>}}
        allowconnectedcdrom = &{If (($vm | Get-CDDrive).IsoPath -eq $null) {$false} Else {$true}}
        allowcpulimit       = &{If (($vm | Get-VMResourceConfiguration).CpuLimitMhz -eq -1) {$false} Else {$true}}
        allowmemorylimit    = &{If (($vm | Get-VMResourceConfiguration).MemLimitMB -eq -1) {$false} Else {$true}}
        syncTimeWithHost    = ($vm | Get-View).Config.Tools.SyncTimeWithHost
        bootDelay           = ($vm | Get-View).Config.BootOptions.BootDelay
    }
    Write-Host ''
    $config.vm

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

#region storage
    $nfsValues = Get-AdvancedSetting -Entity $esxi -Name 'nfs*'

    # Explain each setting
    Write-Host "`n  ### NFS Settings" -ForegroundColor Green
    Write-Host "Plug in your vendor's recommended NFS configuration values."
    Write-Host "Example: Tegile's Zebi array -- 32, 30, 20, 256, 32, 1536"
    Write-Host '  ###' -ForegroundColor Green

    # Set the section's config, and then display it for review
    $config.nfsadvconfig = [ordered]@{
        'NFS.MaxQueueDepth'      = ($nfsValues | Where Name -eq 'NFS.MaxQueueDepth').Value
        'NFS.DeleteRPCTimeout'   = ($nfsValues | Where Name -eq 'NFS.DeleteRPCTimeout').Value
        'NFS.HeartbeatFrequency' = ($nfsValues | Where Name -eq 'NFS.HeartbeatFrequency').Value
        'NFS.MaxVolumes'         = ($nfsValues | Where Name -eq 'NFS.MaxVolumes').Value
        'Net.TcpipHeapSize'      = ($nfsValues | Where Name -eq 'NFS.TcpipHeapSize').Value
        'Net.TcpipHeapMax'       = ($nfsValues | Where Name -eq 'NFS.TcpipHeapMax').Value
    }
    Write-Host ''
    $config.nfsadvconfig

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

#region network
    $vdsList = Get-Datacenter -Name $config.scope.datacenter | Get-VDSwitch -Name $config.scope.vds | Sort Name

    If ($vdsList.Count -gt 1) {
        Write-Host ''

        # List VDS options to choose from
        for ($i = 1; $i -le $vdsList.Count; $i++) {
            Write-Host "$i. " -ForegroundColor Green -NoNewline
            Write-Host "$($vdsList.Name[$i-1])"
        }

        # Pick a VDS (repeat until valid input)
        while (1..$vdsList.Count -notcontains $vdsSelection) {
            $vdsSelection = [int](Read-HostColor "`n-- Select the number of the VDS to pull values from")
        }
        $vds = $vdsList[$vdsSelection - 1]
    } ElseIf ($vdsList.Count -eq 1) {
        # If only one VDS, skip the manual prompt
        $vds = $vdsList
    } Else {
        # No VDS found; $null the values to skip VDS tests
        $vds = @{
            LinkDiscoveryProtocol = $null
            LinkDiscoveryProtocolOperation = $null
            Mtu = $null
        }
    }

    # Explain each setting
    Write-Host "`n  ### VDS (vSphere Distributed Switch) Settings" -ForegroundColor Green
    Write-Host 'linkproto     = [string] LLDP or CDP'
    Write-Host 'linkoperation = [string] Listen, Advertise, Both, Disabled'
    Write-Host 'mtu           = [int] Maximum Transmission Unit. Max is 9000'
    Write-Host '  ###' -ForegroundColor Green

    # Set the section's config, and then display it for review
    $config.vds = [ordered]@{
            linkproto     = $vds.LinkDiscoveryProtocol
            linkoperation = $vds.LinkDiscoveryProtocolOperation
            mtu           = $vds.Mtu
    }
    Write-Host ''
    $config.vds

    If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
        # TODO: Implement line-item review/override
        Write-Warning 'Line item override not yet implemented. Edit the Config.json file after completion.'
    }
#endregion

    Write-Verbose "Creating config file at $OutputFolder\Config.json"
    $config | ConvertTo-Json | Out-File $OutputFolder\Config.json

    If (Test-Path $OutputFolder\Config.json) {
        Write-Host "Config file created at " -ForegroundColor Green -NoNewline
        Write-Host "$OutputFolder\Config.json"
    } Else {
        Write-Warning "Failed to create config file at $OutputFolder\Config.json"
    }
}
