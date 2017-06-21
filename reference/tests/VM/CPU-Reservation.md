# CPU Reservation
Specifies a CPU reservation which makes sure the VM always has the specified amount of CPU MHz reserved
## Discovery Code
```powershell
    [int]$Object.ExtensionData.Config.CpuAllocation.Reservation
```

## Remediation Code
```powershell
    $Object | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuReservationMhz $Desired
```
