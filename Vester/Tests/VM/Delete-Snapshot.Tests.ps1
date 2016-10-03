#requires -Modules Pester, VMware.VimAutomation.Core

[CmdletBinding(SupportsShouldProcess = $true, 
               ConfirmImpact = 'Medium')]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # $Cfg hastable imported in Invoke-Vester
    [Hashtable]$Cfg,

    # VIserver Object
    [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl]$VIServer
)

Process {
    # Tests
    Describe -Name 'VM Configuration: Snapshot(s)' -Tag @("vm") -Fixture {
        # Variables
        [int]$snapretention = $cfg.vm.snapretention

        foreach ($VM in (Get-Datacenter -name $cfg.scope.datacenter -Server $VIServer | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host | Get-VM -Name $cfg.scope.vm)) 
        {
            It -name "$($VM.name) has no snapshot older than $snapretention day(s)" -test {
                [array]$value = $VM |
                Get-Snapshot |
                Where-Object -FilterScript {
                    $_.Created -lt (Get-Date).AddDays(-$snapretention)
                }
                try 
                {
                    $value | Should BeNullOrEmpty
                }
                catch 
                {
                    if ($Remediate) 
                    {
                        Write-Warning -Message $_
                        # TODO: Update ShouldProcess with useful info
                        if ($PSCmdlet.ShouldProcess("Target", "Operation"))
                        {
                            Write-Warning -Message "Remediating $VM"
                            Remove-Snapshot -Snapshot $value -ErrorAction Stop -Confirm:$false
                        }
                    }
                    else 
                    {
                        throw $_
                    }
                }
            }
        }
    }
}
