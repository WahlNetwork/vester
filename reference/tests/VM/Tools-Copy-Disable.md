# Tools Copy Disable
On/Off switch to explicitly disable Copy operations through VM Tools - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.copy.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.copy.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.copy.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.copy.disable'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
