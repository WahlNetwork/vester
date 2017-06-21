# Tools - VM Host Info Access
Control access to host information from guests
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'tools.guestlib.enableHostInfo'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'tools.guestlib.enableHostInfo') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'tools.guestlib.enableHostInfo' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'tools.guestlib.enableHostInfo'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
