# VMX Unity Active Disable
On/Off switch to disable unexposed VMX setting Unity Active - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.unityActive.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.unityActive.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.unityActive.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.unityActive.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
