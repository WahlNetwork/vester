#Requires -Modules Pester, VMware.VimAutomation.Core

function Invoke-VesterTest {
    [CmdletBinding(SupportsShouldProcess = $true,
                   ConfirmImpact = 'Medium')]
    Param(
        # Test file
        [string]$Test,

        [string]$Scope,

        # $Cfg hashtable imported in Invoke-Vester
        [object]$Cfg,

        # Optionally fix all config drift that is discovered
        [switch]$Remediate,

        [string]$XML

    )

    If ($Scope -eq 'Network' -and (Get-Module VMware.VimAutomation.Vds) -eq $null) {
        Try {
            Import-Module VMware.VimAutomation.Vds -ErrorAction Stop
        } Catch {
            throw 'Failed to import PowerCLI module "VMware.VimAutomation.Vds"'
        }
    }

    # Pull in $Title/$Desired/$Actual/$Fix from the test file
    . $Test

    # Pump the brakes if the config value is $null
    If ($Desired -eq $null) {
        Write-Verbose "Due to null config value, skipping test $(Split-Path $Test -Leaf)"
    } Else {
        $Datacenter = Get-Datacenter -name $cfg.scope.datacenter -Server $cfg.vcenter.vc
        $InventoryList = switch ($Scope) {
            'vCenter'    {$cfg.vcenter.vc}
            'Datacenter' {$Datacenter}
            'Cluster'    {$Datacenter | Get-Cluster -Name $cfg.scope.cluster}
            'Host'       {$Datacenter | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host}
            'VM'         {$Datacenter | Get-Cluster -Name $cfg.scope.cluster | Get-VM -Name $cfg.scope.vm}
            'Network'    {$Datacenter | Get-VDSwitch -Name $cfg.scope.vds}
        }

        If ($XML) {
            Invoke-Pester -OutputFormat NUnitXml -OutputFile $XML -Script @{
                Path = "$($PSScriptRoot)\Template\VesterTemplate.Tests.ps1"
                Parameters = @{
                    Remediate     = $Remediate
                    Scope         = $Scope
                    InventoryList = $InventoryList
                    Title         = $Title
                    Desired       = $Desired
                    Actual        = $Actual
                    Fix           = $Fix
                }
            } # Invoke-Pester
        } Else {
            Invoke-Pester -Script @{
                Path = "$($PSScriptRoot)\Template\VesterTemplate.Tests.ps1"
                Parameters = @{
                    Remediate     = $Remediate
                    Scope         = $Scope
                    InventoryList = $InventoryList
                    Title         = $Title
                    Desired       = $Desired
                    Actual        = $Actual
                    Fix           = $Fix
                }
            } # Invoke-Pester
        } #If XML
    } #If Desired
} #Function
