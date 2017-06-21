# Tools Set Info Size Limit
Specify the size limit of the VMX file
## Discovery Code
```powershell
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'tools.setInfo.sizeLimit'}).Value
```

## Remediation Code
```powershell
    if ((Get-AdvancedSetting -Entity $Object -Name 'tools.setInfo.sizeLimit') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'tools.setInfo.sizeLimit' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'tools.setInfo.sizeLimit'
            } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
```
