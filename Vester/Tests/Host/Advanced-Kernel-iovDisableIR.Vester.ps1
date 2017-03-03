# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# Host Kernel Setting iovDisableIR - https://kb.vmware.com/kb/1030265 and https://virtuallyjason.blogspot.com/2017/02/psods-and-iovdisableir-setting.html

# Test title, e.g. 'DNS Servers'
$Title = 'Kernel Setting iovDisableIR'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Disables (or enables) Interrupt Remapping, see VMware KB 1030265'

# The config entry stating the desired values
$Desired = $cfg.host.iovdisableir

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    ( (Get-EsxCli -VMHost $Object -v2).system.settings.kernel.list.invoke() | ? {$_.name -like 'iovDisableIR'}).Configured
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
	#Get-EsxCli doesn't support -WhatIf, so this hack ensures we don't accidentally change the environment
	if(! $WhatIfPreference.isPresent) {
		(Get-EsxCli -VMHost $Object -v2).system.settings.kernel.set.Invoke(@{"setting" = "iovDisableIR"; "value" = $Desired})
	}
}
