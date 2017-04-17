# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'SDRS Automation Override: IO Load Balance'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Specifies the behavior of SDRS when it generated recommendations for correcting I/O load imbalance in a datastore cluster'

# The config entry stating the desired values
$Desired = $cfg.dscluster.autooverrideioloadbalance

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.AutomationOverrides.IoLoadBalanceAutomationMode
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $DefaultVMBehavior = $Save.Value.DSCluster.sdrsautomationlevel
    $SpaceLoadBalanceAutomationMode = $Save.Value.DSCluster.autooverridespaceloadbalance
    $RuleEnforcementAutomationMode = $Save.Value.DSCluster.autooverrideruleenf
    $PolicyEnforcementAutomationMode = $Save.Value.DSCluster.autooverridepolicyenf
    $VmEvacuationAutomationMode = $Save.Value.DSCluster.autooverridevmevac

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    # The DefaultVMBehavior must be specified
    $Spec.PodConfigSpec.DefaultVMBehavior = "automated"
    $Spec.PodConfigSpec.AutomationOverrides = New-Object VMware.Vim.StorageDrsAutomationConfig
    # Only sets the value if it is not null
    if($Desired -ne $NULL)
    {
        $Spec.PodConfigSpec.AutomationOverrides.IoLoadBalanceAutomationMode = $Desired
    }
    # Sets the existing automation overrides
    $Spec.PodConfigSpec.AutomationOverrides.SpaceLoadBalanceAutomationMode = $SpaceLoadBalanceAutomationMode
    $Spec.PodConfigSpec.AutomationOverrides.RuleEnforcementAutomationMode = $RuleEnforcementAutomationMode
    $Spec.PodConfigSpec.AutomationOverrides.PolicyEnforcementAutomationMode = $PolicyEnforcementAutomationMode
    $Spec.PodConfigSpec.AutomationOverrides.VmEvacuationAutomationMode = $VmEvacuationAutomationMode
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)

    # Resets the SDRS Mode back to its default if needed
    if($DefaultVMBehavior -ne "FullyAutomated")
    {
        Write-Verbose "Settings the SDRS automation level back to disabled"
        Set-DatastoreCluster -DatastoreCluster $Object -SDRSAutomationLevel $DefaultVMBehavior
    }
}