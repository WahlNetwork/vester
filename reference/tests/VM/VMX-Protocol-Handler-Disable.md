# VMX Protocol Handler Disable
On/Off switch to disable unexposed VMX setting Protocol Handler - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.ghi.protocolhandler.info.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.protocolhandler.info.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.protocolhandler.info.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.ghi.protocolhandler.info.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
