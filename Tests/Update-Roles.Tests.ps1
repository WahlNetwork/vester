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
    # Variables
    Invoke-Expression -Command (Get-Item -Path $Config)
    $virolescommand = $global:config.roles.vcenterrolespath +"\Import-VIRole.ps1"
    #Source Import-VIRole stuff
    . $virolescommand 
    # Tests
    Describe -Name "vCenter Roles and Privs" -Fixture {
        foreach ( $role in $global:config.Roles.Present){
            It -name "vCenter Role $Role is present" -test {
               $roleinfo = Get-VIRole -name $role -ErrorAction SilentlyContinue 
               try{
                    $roleinfo | should not BeNullOrEmpty
               } catch { 
                    if ($Remediate) { 
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $Role"
                            $virolesconfig = $global:config.roles.descriptionpath + "\" + $Role + ".json"  
                            $vcname = $global:config.vcenter.vc
                            Write-Host " Running Import-ViRole  $role $virolesconfig $vcname"
                            Import-VIRole $role $virolesconfig $vcname
                    } else {
                        throw $_
                    }
               }
            }
            It -name "vCenter Role $Role Privs correct" -test {
                $roleInfo = Get-VIRole -name $Role
                try {
                    $privList = $RoleInfo.PrivilegeList
                    $roleFile = $global:config.roles.descriptionpath + "\" + $Role + ".json"
                    Test-Path $roleFile
                    $refRoleInfo = Get-Content -Path ($roleFile) | ConvertFrom-Json
                    $refPrivList = $RefRoleInfo.Privileges
                    Compare-Object -ReferenceObject $refPrivList -DifferenceObject $privList | Should Be $Null
                } catch {
                    if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Remediating $Role Privileges"
                            $virolesconfig = $global:config.roles.descriptionpath + "\" + $Role + ".json"  
                            $vcname = $global:config.vcenter.vc
                            Write-Host " Running Import-ViRole  $role $virolesconfig $vcname"
                            Import-VIRole -Name $role -Permission $virolesconfig -vCenter $vcname -OverWrite:$true 
                    } else {
                        throw $_
                       
                    }
                }
                
                
            }
        }
    }
}
      