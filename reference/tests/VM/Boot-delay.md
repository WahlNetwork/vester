# Boot delay
The time between when you power on the virtual machine and when it exits the BIOS and launches the guest operating system
## Discovery Code
```powershell
    [int]$Object.ExtensionData.Config.BootOptions.BootDelay
```

## Remediation Code
```powershell
	$VMBootOptions = New-Object VMware.Vim.VirtualMachineBootOptions
	$VMBootOptions.BootDelay = $Desired
	$VMConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$VMConfigSpec.BootOptions = $VMBootOptions
	$Object.ExtensionData.ReconfigVM($VMConfigSpec)
```
