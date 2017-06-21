# Tools GUI Options
On/Off switch to explicitly enable Copy/Paste operations through the GUI - Recommended setting of False
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.setguioptions.enable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.setguioptions.enable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.setguioptions.enable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.setguioptions.enable'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
