# Transparent Page Share Force Salting
0 (TPS enabled) 1 (TPS enabled for VMs with same salt) 2 (No inter-VM TPS)
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Mem.ShareForceSalting'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Mem.ShareForceSalting'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
