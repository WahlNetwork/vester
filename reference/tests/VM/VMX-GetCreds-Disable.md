# VMX GetCreds Disable
On/Off switch to disable unexposed VMX setting GetCreds - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.getCreds.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.getCreds.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.getCreds.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.getCreds.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
