# VMX Shell Action Disable
On/Off switch to disable unexposed VMX setting Shell Action - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.ghi.host.shellAction.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.ghi.host.shellAction.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.ghi.host.shellAction.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.ghi.host.shellAction.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
