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

        # Optionally fix all config drift that is discovered. Defaults to false (off)
        [switch]$Remediate = $false

    )

    Begin {
        If ($Scope -eq 'Network' -and (Get-Module VMware.VimAutomation.Vds) -eq $null) {
            Try {
                Import-Module VMware.VimAutomation.Vds -ErrorAction Stop
            } Catch {
                throw 'Failed to import PowerCLI module "VMware.VimAutomation.Vds"'
            }
        }
    }

    Process {
        Describe -Name "$Scope Configuration: $(Split-Path $Test -Leaf)" -Fixture {
            . $Test

            # Pump the brakes if the config value is $null
            If ($Desired -eq $null)
            {
                Write-Verbose "Due to null config value, skipping test $(Split-Path $Test -Leaf)"
            }
            Else
            {
                $Datacenter = Get-Datacenter -name $cfg.scope.datacenter -Server $cfg.vcenter.vc
                $InventoryList = switch ($Scope)
                {
                    'Datacenter' {$Datacenter}
                    'Cluster'    {$Datacenter | Get-Cluster -Name $cfg.scope.cluster}
                    'Host'       {$Datacenter | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host}
                    'VM'         {$Datacenter | Get-Cluster -Name $cfg.scope.cluster | Get-VM -Name $cfg.scope.vm}
                    'Network'    {$Datacenter | Get-VDSwitch -Name $cfg.scope.vds}
                }

                ForEach ($Object in $InventoryList)
                {
                    It -Name "$Scope $($Object.name) - $Title" -Test {
                        # Call the command from the test file
                        $Value = & $Actual

                        try 
                        {
                            Compare-Object -ReferenceObject $Desired -DifferenceObject $Value | Should Be $null
                        }
                        catch 
                        {
                            if ($Remediate) 
                            {
                                Write-Warning -Message $_
                                if ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - $Scope '$Object'", "Set '$Title' value to '$Desired'"))
                                {
                                    Write-Warning -Message "Remediating $Object"
                                    & $Fix
                                }
                            }
                            else 
                            {
                                throw $_
                            }
                        } #Try/Catch
                    } #It
                } #ForEach
            } #If Desired
        } #Describe
    } #Process
} #Function
