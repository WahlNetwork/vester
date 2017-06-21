# SDRS Automation Override: VM Evacuation
Specifies the behavior of SDRS when it generates recommendations for datastore evacuations in a datastore cluster
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.AutomationOverrides.VmEvacuationAutomationMode
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $DefaultVMBehavior = $Save.Value.DSCluster.sdrsautomationlevel
    $SpaceLoadBalanceAutomationMode = $Save.Value.DSCluster.autooverridespaceloadbalance
    $IoLoadBalanceAutomationMode = $Save.Value.DSCluster.autooverrideioloadbalance
    $RuleEnforcementAutomationMode = $Save.Value.DSCluster.autooverrideruleenf
    $PolicyEnforcementAutomationMode = $Save.Value.DSCluster.autooverridepolicyenf

    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    # The DefaultVMBehavior must be specified
    $Spec.PodConfigSpec.DefaultVMBehavior = "automated"
    $Spec.PodConfigSpec.AutomationOverrides = New-Object VMware.Vim.StorageDrsAutomationConfig
    # Only sets the value if it is not null
    if($Desired -ne $NULL)
    {
        $Spec.PodConfigSpec.AutomationOverrides.VmEvacuationAutomationMode = $Desired
    }
    # Sets the existing automation overrides
    $Spec.PodConfigSpec.AutomationOverrides.SpaceLoadBalanceAutomationMode = $SpaceLoadBalanceAutomationMode
    $Spec.PodConfigSpec.AutomationOverrides.IoLoadBalanceAutomationMode = $IoLoadBalanceAutomationMode
    $Spec.PodConfigSpec.AutomationOverrides.RuleEnforcementAutomationMode = $RuleEnforcementAutomationMode
    $Spec.PodConfigSpec.AutomationOverrides.PolicyEnforcementAutomationMode = $PolicyEnforcementAutomationMode
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)

    # Resets the SDRS Mode back to its default if needed
    if($DefaultVMBehavior -ne "FullyAutomated")
    {
        Write-Verbose "Settings the SDRS automation level back to disabled"
        Set-DatastoreCluster -DatastoreCluster $Object -SDRSAutomationLevel $DefaultVMBehavior
    }
```
