# Isolation - Device Interaction Edit
Prevent unauthorized users from connecting, disconnecting, or editing devices or network adapters
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.device.edit.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.device.edit.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.device.edit.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.device.edit.disable'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
