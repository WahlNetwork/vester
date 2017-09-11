# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1

# Test title, e.g. 'DNS Servers'
$Title = 'VUM Attached Baselines'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'Manages attached VMware Update Manager baselines.  Baseline names are stored as a semicolon separated list.'

# The config entry stating the desired values
$Desired = $cfg.cluster.vumattachedbaselines

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    $attachedBaselines = $Object | Get-Baseline
    if($attachedBaselines) {
        $attachedBaselines.name -join ";"
    } else {
        $null
    }
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if($Desired) {
        #Add/Remove baselines
	$desiredBaselines = $Desired -split ";"

        # Attach desired baseline(s)
	$desiredBaselines | % {
            $Object | Attach-Baseline -Baseline (Get-Baseline -Name $_)
	}

	# Remove undesired baseline(s)
	$Object | Get-Baseline | % {
	    if(! ($desiredBaselines -contains $_.Name) ) {
	        $_ | Detach-Baseline -Entity $Object
	    }
	}
    } else {
        # Remove all attached baseline(s)
        $Object | Get-Baseline | Detach-Baseline -Entity $Object
    }
}
