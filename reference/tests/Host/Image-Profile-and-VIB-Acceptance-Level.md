# Image Profile and VIB Acceptance Level
VMwareCertified, VMwareAccepted, PartnerSupported (default), CommunitySupported
## Discovery Code
```powershell
    (Get-EsxCli -VMHost $Object -v2).software.acceptance.get.Invoke()
```

## Remediation Code
```powershell
    (Get-EsxCli -VMHost $Object -v2).software.acceptance.set.Invoke(@{"level" = $Desired})
```
