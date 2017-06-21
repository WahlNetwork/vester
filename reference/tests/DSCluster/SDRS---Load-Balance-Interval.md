# SDRS - Load Balance Interval
Specifies the interval where SDRS checks for storage imbalances (4 hour default)
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.LoadBalanceInterval
```

## Remediation Code
```powershell
    $Save = Get-ChildItem Variable: | Where-Object {$_.Value -Match "dscluster"}
    $SDRSEnabled = $Save.Value.DSCluster.sdrsautomationlevel
    # Gets the desired SDRS automation level
    if(($SDRSEnabled -eq "FullyAutomated") -or ($SDRSEnabled -eq "Manual"))
    {
	    $SDRSEnabled = $TRUE
    }
    else
    {
        $SDRSEnabled = $FALSE
    }
    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.LoadBalanceInterval = $Desired
    $Spec.PodConfigSpec.Enabled = $SDRSEnabled
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef,$Spec,$TRUE)
```
