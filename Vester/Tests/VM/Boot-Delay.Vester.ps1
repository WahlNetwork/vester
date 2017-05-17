# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Boot delay'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'The time between when you power on the virtual machine and when it exits the BIOS and launches the guest operating system'

# The config entry stating the desired values
$Desired = $cfg.vm.bootdelay

# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    [int]$Object.ExtensionData.Config.BootOptions.BootDelay
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	$VMBootOptions = New-Object VMware.Vim.VirtualMachineBootOptions
	$VMBootOptions.BootDelay = $Desired
	$VMConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$VMConfigSpec.BootOptions = $VMBootOptions
	$Object.ExtensionData.ReconfigVM($VMConfigSpec)
}