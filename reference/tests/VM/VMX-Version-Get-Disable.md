# VMX Version Get Disable
On/Off switch to disable unexposed VMX setting Version Get - Recommended setting of True
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.vmxDnDVersionGet.disable'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.vmxDnDVersionGet.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.vmxDnDVersionGet.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.vmxDnDVersionGet.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
