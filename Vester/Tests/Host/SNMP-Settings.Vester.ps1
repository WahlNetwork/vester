# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Ensure proper SNMP configuration'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'If SNMP is not being used, it should remain disabled. If it is being used, the proper trap destination should be configured.'

# The config entry stating the desired values
$Desired = $cfg.host.configsnmp

# The test value's data type, to help with conversion: bool/string/int
$Type = 'hashtable'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $ht2 = @{}
    ((Get-ESXCli -v2 -VMHost $Object).system.snmp.get.invoke()).psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }
    $ht2
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $EsxCli = (Get-EsxCli -v2 -VMhost $Object)
    $Arguments = $EsxCli.system.snmp.set.CreateArgs()
    ForEach ($key in $Desired.Keys){
        if($Desired."$key" -ne $null -and $Desired."$key" -ne ''){
        $Arguments."$key"=$Desired."$key"
        }
    }
    $EsxCli.system.snmp.set.Invoke($Arguments)
}