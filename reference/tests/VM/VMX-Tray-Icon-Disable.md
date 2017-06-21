# VMX Tray Icon Disable
On/Off switch to disable unexposed VMX setting Tray Icon - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.ghi.trayicon.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.trayicon.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.trayicon.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.ghi.trayicon.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
