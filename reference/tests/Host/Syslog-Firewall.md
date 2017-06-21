# Syslog Firewall
On/off switch to set a Syslog exception in the host firewall
## Discovery Code
```powershell
    ($Object | Get-VMHostFirewallException -name syslog).Enabled
```

## Remediation Code
```powershell
    $Object | Get-VMHostFirewallException -name syslog | Set-VMHostFirewallException -Enabled $Desired -ErrorAction Stop
```
