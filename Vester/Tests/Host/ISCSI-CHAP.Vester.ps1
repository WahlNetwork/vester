# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'ISCSI CHAP Settings'

# Test description: How New-VesterConfig explains this value to the user
$Description = "Specifies the ISCSI CHAP settings for the host"

# The config entry stating the desired values
$Desired = $cfg.host.iscsichap

# The test value's data type, to help with conversion: bool/string/int
$Type = 'hashtable'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $ht2 = @{}
    ($Object | Get-VMHostHba | Where {$_.Type -eq "Iscsi"} | Select -ExpandProperty AuthenticationProperties).psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }
    $ht2
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ($Desired.ChapType -ne 'Prohibited') {
	    $CHAPpass = Read-Host "Enter a password for outgoing CHAP Credential" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($CHAPpass)
        $CHAPpasstext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        if ($Desired.MutualChapEnabled) {
		    $MutualChapPass = Read-Host "Enter a password for incoming CHAP Credential" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MutualChapPass)
            $MutualChapPasstext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            $Object | Get-VMHostHba | Where {$_.Type -eq "Iscsi"} | Set-VMHostHba -ChapType $Desired.ChapType -ChapName $Desired.ChapName -ChapPassword $CHAPpasstext -MutualChapName $Desired.MutualChapName -MutualChapPassword $MutualChapPasstext -Confirm:$false
		}
		else{
		    $Object | Get-VMHostHba | Where {$_.Type -eq "Iscsi"} | Set-VMHostHba -ChapType $Desired.ChapType -ChapName $Desired.ChapName -ChapPassword $CHAPpasstext -Confirm:$false
		}
	}
}