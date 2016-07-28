$global:config = @{}

<########################################################################################
        Scope Settings
        This dictates the scope of your vSphere environment that will be tested by Pester.
        Use string values. Wildcards are accepted.
        cluster = [string] vSphere cluster names
        host = [string] ESXi host names
        vm = [string] Virtual machine names
#>

$global:config.scope = @{
    cluster = '*'
    host    = '*'
    vm      = '*'
}

<########################################################################################
        vCenter Settings
        vc = [string] vCenter IP Address
#>

$global:config.vcenter = @{
    vc = "ushnhcp1vccvum1"
}

<########################################################################################
        Cluster Settings
        drsmode = [string] FullyAutomated, Manual, or PartiallyAutomated
        drslevel = [int] 1 (Aggressive), 2, 3, 4, 5 (Conservative)
#>

$global:config.cluster = @{
    drsmode  = 'FullyAutomated'
    drslevel = 3
}

<########################################################################################
        ESXi Host Settings
        sshenable = [bool] $true or $false
        sshwarn = [int] 1 (off) or 0 (on)
        esxntp = [array] @('NTP Server 1', 'NTP Server 2 (optional)', 'NTP Server 3 (optional)', 'NTP Server 4 (optional)')
        esxdns = [array] @('DNS Server 1', 'DNS Server 2 (optional)')
        searchdomains = [array] @('Domain 1', 'Domain 2 (optional)')
        esxsyslog = [array] @('tcp://ip_address:port')
#>


$global:config.host = @{
    sshenable     = $true
    sshwarn       = 1
    esxntp        = @('timesvr1.nike.com','timesvr2.nike.com')
  #  esxdns        = @()
    searchdomains = @('nike.com','ad.nike.com')
    esxsyslog     = @('tcp://172.16.20.243:514')
}

<########################################################################################
        VM Settings
        snapretention = [int] Allowed number of days for a VM snapshot to exist
        allowconnectedcdrom = [bool] $true or $false
#>

$global:config.vm = @{
    snapretention       = 9999
    allowconnectedcdrom = $false
}

<########################################################################################
        NFS Settings
        Plug in your vendor's recommended NFS configuration values. Example: Tegile's Zebi array.
#>
<#
$global:config.nfsadvconfig = @{
    'NFS.MaxQueueDepth'    = 32
    'NFS.DeleteRPCTimeout' = 30
    'NFS.HeartbeatFrequency' = 20
    'NFS.MaxVolumes'       = 256
    'Net.TcpipHeapSize'    = 32
    'Net.TcpipHeapMax'     = 1536
}
#>

<########################################################################################
        Roles and Privileges Settings
        Leveraging vCenter-Roles from https://github.com/rnelson0/vCenter-roles.
#>
$global:config.roles= @{
    vcenterrolespath = "H:\Src\github\vcenter-roles"
    defaultRoleFilePath = "H:\src\github\vcenter-roles\roles"
    rolesPresent = @{"loginsight"    = "loginsight3.json";
                     "vestertest"    = "H:\Vestertest.json"
                     "rubrik"        = "rubrik.json"
    }
    Present = @("Administrator","logInsight","VesterTest","rubrik")
}

