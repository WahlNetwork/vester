# Sync Time Settings
VMware Tools sets the time of the guest operating system to be the same as the time of the host
## Discovery Code
```powershell
    $Object.ExtensionData.Config.Tools.SyncTimeWithHost
```

## Remediation Code
```powershell
    $Spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $Spec.ChangeVersion = $Object.ExtensionData.Config.ChangeVersion
    $Spec.Tools = New-Object VMware.Vim.ToolsConfigInfo
    $Spec.Tools.SyncTimeWithHost = $Desired
    $Object.ExtensionData.ReconfigVM_Task($Spec)
```
