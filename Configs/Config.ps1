$config = @{}

<########################################################################################
        Scope Settings
        This dictates the scope of your vSphere environment that will be tested by Pester.
        Use string values. Wildcards are accepted.
        cluster = [string] vSphere cluster names
        host = [string] ESXi host names
        vm = [string] Virtual machine names
        vds = [string] vSphere Distributed Switch (VDS) names
#>

$config.scope = @{
    cluster = '*'
    host    = '*'
    vm      = '*'
    vds     = '*'

}

<########################################################################################
        vCenter Settings
        vc = [string] vCenter IP Address
#>

$config.vcenter = @{
    vc = [string]'172.17.48.17'
}

<########################################################################################
        Cluster Settings
        drsmode = [string] FullyAutomated, Manual, or PartiallyAutomated
        drslevel = [int] 1 (Aggressive), 2, 3, 4, 5 (Conservative)
        haenable = [bool] $true or $false
#>

$config.cluster = @{
    drsmode  = [string]'FullyAutomated'
    drslevel = [int]2
    haenable = [bool]$true
}

<########################################################################################
        ESXi Host Settings
        sshenable = [bool] $true or $false
        sshwarn = [int] 1 (off) or 0 (on)
        esxntp = [array] @('NTP Server 1', 'NTP Server 2 (optional)', 'NTP Server 3 (optional)', 'NTP Server 4 (optional)')
        esxdns = [array] @('DNS Server 1', 'DNS Server 2 (optional)')
        searchdomains = [array] @('Domain 1', 'Domain 2 (optional)')
        esxsyslog = [array] @('tcp://ip_address:port')
        esxsyslogfirewallexception = [bool] $true or $false
#>


$config.host = @{
    sshenable     = [bool]$true
    sshwarn       = [int]1
    esxntp        = @('0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org')
    esxdns        = @('172.17.48.11', '172.17.48.12')
    searchdomains = @('rubrik.demo')
    esxsyslog     = @('tcp://172.16.20.243:514')
    esxsyslogfirewallexception  = [bool]$true
}

<########################################################################################
        VM Settings
        snapretention = [int] Allowed number of days for a VM snapshot to exist
        allowconnectedcdrom = [bool] $true or $false
        allowcpulimit = [bool] $true or $false
        allowmemorylimit = [bool] $true or $false
#>

$config.vm = @{
    snapretention       = [int]9999
    allowconnectedcdrom = [bool]$false
    allowcpulimit       = [bool]$false
    allowmemorylimit    = [bool]$false
}

<########################################################################################
        NFS Settings
        Plug in your vendor's recommended NFS configuration values. Example: Tegile's Zebi array.
#>

$config.nfsadvconfig = @{
    'NFS.MaxQueueDepth'    = [int]32
    'NFS.DeleteRPCTimeout' = [int]30
    'NFS.HeartbeatFrequency' = [int]20
    'NFS.MaxVolumes'       = [int]256
    'Net.TcpipHeapSize'    = [int]32
    'Net.TcpipHeapMax'     = [int]1536
}

<########################################################################################
        VDS (vSphere Distributed Switch) Settings
        linkproto = [string] LLDP or CDP 
        linkoperation = [string] Listen, Advertise, Both, Disabled
        mtu = [int] Maximum Transmission Unit. Max is 9000.
#>

$config.vds = @{
        linkproto = [string]'LLDP'
        linkoperation = [string]'Both'
        mtu = [int]1500
}
