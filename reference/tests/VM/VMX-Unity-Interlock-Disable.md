# VMX Unity Interlock Disable
On/Off switch to disable unexposed VMX setting Unity Interlock - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.unityInterlockOperation.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.unityInterlockOperation.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.unityInterlockOperation.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.unityInterlockOperation.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
