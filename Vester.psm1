#Requires -Modules Pester, VMware.VimAutomation.Core

<#
.SYNOPSIS
PowerCLI and Pester team up against your vSphere environment.

.DESCRIPTION
TODO: Write a full comment-based help section
#>
function Invoke-Vester {
    [CmdletBinding(SupportsShouldProcess = $true, 
                   ConfirmImpact = 'Medium')]
    param (
        # Optionally fix all config drift that is discovered. Defaults to false (off)
        [switch]$Remediate = $false,

        # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
        [string]$Config = '.\Configs\Config.ps1',

        # Optionally run only tests that match the given tag(s)
        [ValidateSet('cluster','host','network','nfs','storage','vcenter','vds','vm')]
        # TODO: ^ That should be dynamic
        [string[]]$Tag,

        # Optionally exclude tests with the given tag(s)
        [ValidateSet('cluster','host','network','nfs','storage','vcenter','vds','vm')]
        # TODO: ^ That should be dynamic
        [string[]]$ExcludeTag
    )

    BEGIN {
        # Put the logic to check for active Connect-VIServer session here
        # See Config.Tests.ps1
    }

    PROCESS {
        Invoke-Pester -Tag $Tag -ExcludeTag $ExcludeTag -Script @{
            # TODO: Figure out what to do with the config test
            Path = '.\Tests\'
            Parameters = @{
                Remediate  = $Remediate
                Config     = $Config
            }
        } # Invoke-Pester
    } # Process
} # function
