<#
Helper function to connect to a vCenter Server and allows self-signed certificates for vCenter connections
#>
function ConnectTovCenter($vCenter) 
{
    Write-Verbose -Message 'Importing required modules and snapins'
    $powercli = Get-PSSnapin -Name VMware.VimAutomation.Core -Registered
    try 
    {
        switch ($powercli.Version.Major) {
            {
                $_ -ge 6
            }
            {
                Import-Module -Name VMware.VimAutomation.Core -ErrorAction Stop
                Write-Verbose -Message 'PowerCLI 6+ module imported'
            }
            5
            {
                Add-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction Stop
                Write-Warning -Message 'PowerCLI 5 snapin added; recommend upgrading your PowerCLI version'
                Write-Warning -Message 'Visit: http://www.vmware.com/go/powercli'
            }
            default 
            {
                throw 'This script requires PowerCLI version 5 or later'
            }
        }
    }
    catch 
    {
        throw $_
    }

    Write-Verbose -Message 'Ignoring self-signed SSL certificates for vCenter Server (optional)'
    $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

    Write-Verbose -Message 'Connecting to vCenter'
    try 
    {
        $null = Connect-VIServer -Server $vCenter -ErrorAction Stop -Session ($global:DefaultVIServers | Where-Object -FilterScript {
                $_.name -eq $vCenter
        }).sessionId
    }
    catch 
    {
        throw $_
    }
}