$global:config = @{}

### vCenter Settings

$global:config.vcenter = @{
    vc = 172.17.48.17
}


### Cluster Settings

$global:config.cluster = @{
    drsmode  = 'FullyAutomated'
    drslevel = 2
}

### ESXi Host Settings

$global:config.host = @{
    sshenable     = $true
    sshwarn       = 1
    esxntp        = @('0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org')
    esxdns        = @('172.16.20.11', '172.16.20.12')
    searchdomains = @('glacier.local')
    esxsyslog     = @('tcp://172.16.20.243:514')
}

# Tegile Zebi array settings

$global:config.nfsadvconfig = @{
    'NFS.MaxQueueDepth'    = 32
    'NFS.DeleteRPCTimeout' = 30
    'NFS.HeartbeatFrequency' = 20
    'NFS.MaxVolumes'       = 256
    'Net.TcpipHeapSize'    = 32
    'Net.TcpipHeapMax'     = 1536
}