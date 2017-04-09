# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'Network Dump Enable'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Network dumps allow the ESXi host to send its core dumps to a remote dump collector'

# The config entry stating the desired values
$Desired = $cfg.host.netdumpenabled

# The test value's data type, to help with conversion: bool/string/int
$Type = 'boolean'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-EsxCli -v2 -VMhost $Object).system.coredump.network.get.Invoke().Enabled
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
# -- NOTE --
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vsphere.install.doc_50%2FGUID-85D78165-E590-42CF-80AC-E78CBA307232.html
# Network core dumps can only be enabled AFTER the network dump settings have been set
[ScriptBlock]$Fix = {
    $EsxCli = (Get-EsxCli -v2 -VMhost $Object)
    $Arguments = $EsxCli.system.coredump.network.set.CreateArgs()
    $Arguments.enable = $Desired
    $EsxCli.system.coredump.network.set.Invoke($Arguments)
}