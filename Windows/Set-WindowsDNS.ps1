#=======================================================================#
#	Set DNS Server entries for clients
#=======================================================================#

# Snapins
Install-WindowsFeature -Name RSAT-AD-PowerShell
Import-Module ActiveDirectory

# Creds
Invoke-Expression ($PSScriptRoot + "\JobVars.ps1")

# Domain Controller 1
$wmi = Get-WmiObject win32_networkadapterconfiguration -ComputerName "dc1.glacier.local" -filter "ipenabled = 'true'"
$wmi.SetDNSServerSearchOrder($DNSServersDC1) | Out-Null

# Domain Controller 2
$wmi = Get-WmiObject win32_networkadapterconfiguration -ComputerName "dc2.glacier.local" -filter "ipenabled = 'true'"
$wmi.SetDNSServerSearchOrder($DNSServersDC2) | Out-Null

# Add the AD module so that we can query for computer objects
Install-WindowsFeature -Name RSAT-AD-PowerShell
Import-Module ActiveDirectory

# Get a list of all the computer objects that AD is aware of
$pclist = get-adcomputer -Filter 'ObjectClass -eq "Computer"' | select -ExpandProperty DNSHostName

# Run through the list and set the DNS server entries for each computer object
foreach ($_ in $pclist) {
    if ($_ -notmatch "DC*") {
        Write-Host "Connecting to $_"
        $wmi = Get-WmiObject win32_networkadapterconfiguration -ComputerName $_ -filter "ipenabled = 'true'"
        $wmi.SetDNSServerSearchOrder($DNSServers) | Out-Null
        }
    }