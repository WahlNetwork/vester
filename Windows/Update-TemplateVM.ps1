########################################################################################################
# Triggers a full set of Windows Updates on Windows VMs in a template folder
########################################################################################################

# Pull in vars
$vars = (Get-Item $PSScriptRoot).Parent.FullName + "\vars.ps1"
Invoke-Expression ($vars)

# Add the required modules
Import-Module PSWindowsUpdate
Add-PSSnapin VMware.VimAutomation.Core

    # Ignore self-signed SSL certificates for vCenter Server (optional)
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

# Connect to vCenter Server
Connect-VIServer $global:vc

# Get a list of template VMs
$VMs = Get-VM -Location (Get-Folder -Name "Templates")

foreach ($VM in $VMs)
    {

    if ($VM.PowerState -eq "PoweredOn" -and $VM.Guest.OSFullName -match "Microsoft")
        {

        # Copy over the PSWindowsUpdate module to the target server
        Copy-Item "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate" -Destination ("\\" + $VM.Guest.HostName + "\C$\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate") -Recurse
        
        # Create a script block for the WUInstaller
        $Script = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -AutoReboot | Out-File C:\PSWindowsUpdate.log}
        
        # Start up a remote task to download updates, install them, and then auto reboot
        Invoke-WUInstall -ComputerName $VM.Guest.HostName -Script $Script -Confirm:$false -TaskName ("WinUpdate-" + (Get-Date).Second)

        # Pull the report showing what KBs are being downloaded and accepted. I tend to leave this commented unless tshooting.
        #Get-Content ("\\" + $VM.Guest.HostName + "\C$\PSWindowsUpdate.log")

        }

    }

Disconnect-VIServer -Confirm:$false