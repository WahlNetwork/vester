#requires -Modules Pester
#requires -Modules VMware.VimAutomation.Core


[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Remediation toggle')]
    [ValidateNotNullorEmpty()]
    [switch]$Remediate,
    [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Path to the configuration file')]
    [ValidateNotNullorEmpty()]
    [string]$Config
)

Process {
    # Tests
    Describe -Name 'VM Configuration: Snaphot(s)' -Tag @("vm") -Fixture {
        # Variables
        . $Config
        [int]$snapretention = $config.vm.snapretention

        foreach ($VM in (Get-VM -Name $config.scope.vm)) 
        {
            It -name "$($VM.name) has no snaphsot older than $snapretention day(s)" -test {
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
                        Write-Warning -Message "Remediating $VM"
                        Remove-Snapshot -Snapshot $value -ErrorAction Stop -Confirm:$false
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