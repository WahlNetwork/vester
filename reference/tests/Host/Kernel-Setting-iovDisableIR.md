# Kernel Setting iovDisableIR
Disables (or enables) Interrupt Remapping, see VMware KB 1030265
## Discovery Code
```powershell
    ( (Get-EsxCli -VMHost $Object -v2).system.settings.kernel.list.invoke() | ? {$_.name -like 'iovDisableIR'}).Configured
```

## Remediation Code
```powershell
	(Get-EsxCli -VMHost $Object -v2).system.settings.kernel.set.Invoke(@{"setting" = "iovDisableIR"; "value" = $Desired})
```
