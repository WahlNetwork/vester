# CPU Limits Test
Optionally disallow VMs from specifying a CPU limit
## Discovery Code
```powershell
    If (($Object | Get-VMResourceConfiguration).CpuLimitMhz -eq -1) {$false} 
    Else {$true}
```

## Remediation Code
```powershell
    If ($Desired -eq $false) {
        $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuLimitMhz $null
    } Else {
        Write-Warning 'CPU tests do not remediate against a desired value of $true'
    }
```
