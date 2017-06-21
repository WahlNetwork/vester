# ESX Admins Group
Security Group allowed root access to ESXi host
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Config.HostAgent.plugins.hostsvc.esxAdminsGroup'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Config.HostAgent.plugins.hostsvc.esxAdminsGroup'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
