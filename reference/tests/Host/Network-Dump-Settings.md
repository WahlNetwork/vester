# Network Dump Settings
Specifies the network dump settings to allow the ESXi host to send its core dumps to a remote dump collector
## Discovery Code
```powershell
	@(
        	(Get-EsxCli -v2 -VMhost $Object).system.coredump.network.get.Invoke().HostVNic;
	        (Get-EsxCli -v2 -VMhost $Object).system.coredump.network.get.Invoke().NetworkServerIP;
	        (Get-EsxCli -v2 -VMhost $Object).system.coredump.network.get.Invoke().NetworkServerPort;
	)
```

## Remediation Code
```powershell
    $EsxCli = (Get-EsxCli -v2 -VMhost $Object)
    $Arguments = $EsxCli.system.coredump.network.set.CreateArgs()
    $Arguments.interfacename    = $Desired[0]
    $Arguments.serveripv4       = $Desired[1]
    $Arguments.serverport       = $Desired[2]
    $EsxCli.system.coredump.network.set.Invoke($Arguments)
```
