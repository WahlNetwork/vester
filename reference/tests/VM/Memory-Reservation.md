# Memory Reservation
Specifies a Memory reservation which makes sure the VM always has the specified amount of RAM reserved
## Discovery Code
```powershell
    [int]$Object.ExtensionData.Config.MemoryAllocation.Reservation
```

## Remediation Code
```powershell
    $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemReservationMB $Desired
```
