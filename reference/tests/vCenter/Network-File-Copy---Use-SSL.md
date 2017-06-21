# Network File Copy - Use SSL
On/Off switch for enabling SSL for Network File Copy. Default is True, however the key does not exist
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object -Name config.nfc.useSSL).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name config.nfc.useSSL) -eq $null) {
        New-AdvancedSetting -Entity $Object -Name config.nfc.useSSL -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'config.nfc.useSSL'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
