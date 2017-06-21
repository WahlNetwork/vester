# Network Dump Enable
Network dumps allow the ESXi host to send its core dumps to a remote dump collector
## Discovery Code
```powershell
    (Get-EsxCli -v2 -VMhost $Object).system.coredump.network.get.Invoke().Enabled
```

## Remediation Code
```powershell
    $EsxCli = (Get-EsxCli -v2 -VMhost $Object)
    $Arguments = $EsxCli.system.coredump.network.set.CreateArgs()
    $Arguments.enable = $Desired
    $EsxCli.system.coredump.network.set.Invoke($Arguments)
```
