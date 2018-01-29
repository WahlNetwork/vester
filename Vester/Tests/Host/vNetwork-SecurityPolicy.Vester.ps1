# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'vNetwork Security Policy'

# Test description: How New-VesterConfig explains this value to the user
$Description = "Specifies vswitch and portgroup security policy settings"

# The config entry stating the desired values
$Desired = $cfg.host.vnetworksecuritypolicy

# The test value's data type, to help with conversion: bool/string/int
$Type = 'hashtable'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $ht2 = @{}
    $Object | Get-VirtualSwitch | Get-SecurityPolicy | Foreach {
        $ht3=@{}
        $_.psobject.properties | Foreach {
            if( @("ForgedTransmits","AllowPromiscuous","MacChanges","AllowPromiscuousInherited","ForgedTransmitsInherited","MacChangesInherited") -contains $_.Name ) {
                $ht3[$_.Name]=$_.Value
            }
        }
        $ht2[$_.VirtualSwitch.Name] = $ht3
    }
    $Object | Get-VirtualPortGroup | Get-SecurityPolicy | Foreach {
        $ht3=@{}
        $_.psobject.properties | Foreach {
            if( @("ForgedTransmits","AllowPromiscuous","MacChanges","AllowPromiscuousInherited","ForgedTransmitsInherited","MacChangesInherited") -contains $_.Name ) {
                $ht3[$_.Name]=$_.Value
            }
        }
        $ht2[$_.VirtualPortGroup.Name] = $ht3
    }
    $ht2
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    $Desired.keys | Foreach {
        if ( $Desired[$_]["ForgedTransmitsInherited"] -ne $null -and $Desired[$_]["MacChangesInherited"] -ne $null -and $Desired[$_]["AllowPromiscuousInherited"] -ne $null ){
            $VirtualPortGroupName = $_
			if ($Desired[$_]["ForgedTransmitsInherited"]) {
				$Object | Get-VirtualPortGroup | Where {$_.name -eq $VirtualPortGroupName} | Get-SecurityPolicy |
					Set-SecurityPolicy -ForgedTransmitsInherited $Desired[$_]["ForgedTransmitsInherited"]
			}
			else{
				$Object | Get-VirtualPortGroup | Where {$_.name -eq $VirtualPortGroupName} | Get-SecurityPolicy |
					Set-SecurityPolicy -ForgedTransmits $Desired[$_]["ForgedTransmits"]
			}
			if ($Desired[$_]["MacChangesInherited"]) {
				$Object | Get-VirtualPortGroup | Where {$_.name -eq $VirtualPortGroupName} | Get-SecurityPolicy |
					Set-SecurityPolicy -MacChangesInherited $Desired[$_]["MacChangesInherited"]
			}
			else{
				$Object | Get-VirtualPortGroup | Where {$_.name -eq $VirtualPortGroupName} | Get-SecurityPolicy |
					Set-SecurityPolicy -MacChanges $Desired[$_]["MacChanges"]
			}
			if ($Desired[$_]["AllowPromiscuousInherited"]) {
				$Object | Get-VirtualPortGroup | Where {$_.name -eq $VirtualPortGroupName} | Get-SecurityPolicy |
					Set-SecurityPolicy -AllowPromiscuousInherited $Desired[$_]["AllowPromiscuousInherited"]
			}
			else{
				$Object | Get-VirtualPortGroup | Where {$_.name -eq $VirtualPortGroupName} | Get-SecurityPolicy |
					Set-SecurityPolicy -AllowPromiscuous $Desired[$_]["AllowPromiscuous"]
			}
        }
        else{
            $VirtualSwitchName = $_
            $Object | Get-VirtualSwitch | Where {$_.name -eq $VirtualSwitchName} | Get-SecurityPolicy |
			    Set-SecurityPolicy -ForgedTransmits $Desired[$_]["ForgedTransmits"] -MacChanges $Desired[$_]["MacChanges"] -AllowPromiscuous $Desired[$_]["AllowPromiscuous"]
        }
    }
}
