# Memory Limits Test
Optionally disallow VMs from specifying a Memory limit
## Discovery Code
```powershell
    If (($Object | Get-VMResourceConfiguration).MemLimitMB -eq -1) {$false} 
    Else {$true}
```

## Remediation Code
```powershell
    If ($Desired -eq $false) {
        $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemLimitMB $null
    } Else {
        Write-Warning 'Memory tests do not remediate against a desired value of $true'
    }
```
