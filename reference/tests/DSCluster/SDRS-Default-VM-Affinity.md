# SDRS Default VM Affinity
Specifies whether to keep VMDKs together by default or not
## Discovery Code
```powershell
    $Object.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultIntraVMAffinity
```

## Remediation Code
```powershell
    $StorMgr = Get-View StorageResourceManager
    $Spec = New-Object VMware.Vim.StorageDrsConfigSpec
    $Spec.PodConfigSpec = New-Object VMware.Vim.StorageDrsPodConfigSpec
    $Spec.PodConfigSpec.DefaultIntraVmAffinity = $Desired
    $StorMgr.ConfigureStorageDrsForPod($Object.ExtensionData.MoRef, $Spec, $TRUE)
```
