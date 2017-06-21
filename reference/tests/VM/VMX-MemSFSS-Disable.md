# VMX MemSFSS Disable
On/Off switch to disable unexposed VMX setting MemScheduleFakeSampleStats - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.memSchedFakeSampleStats.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.memSchedFakeSampleStats.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.memSchedFakeSampleStats.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.memSchedFakeSampleStats.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
