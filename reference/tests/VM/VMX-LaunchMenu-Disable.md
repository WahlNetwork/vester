# VMX LaunchMenu Disable
On/Off switch to disable unexposed VMX setting LaunchMenu - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.ghi.launchmenu.change'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.launchmenu.change') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.launchmenu.change' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.ghi.launchmenu.change'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
