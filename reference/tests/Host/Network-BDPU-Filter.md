# Network BDPU Filter
0 (disable) or 1 (enable) to control the BDPU filter on the ESXi host
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'Net.BlockGuestBPDU'
    }).Value
```

## Remediation Code
```powershell
    Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'Net.BlockGuestBPDU'
        } | Set-AdvancedSetting -Value $Desired -Confirm:$false -ErrorAction Stop
```
