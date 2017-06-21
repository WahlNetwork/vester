# Remote Display VNC setting
On/Off switch to enable/disable VNC for Remote Console
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'RemoteDisplay.vnc.enabled'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'RemoteDisplay.vnc.enabled') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'RemoteDisplay.vnc.enabled' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'RemoteDisplay.vnc.enabled'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
