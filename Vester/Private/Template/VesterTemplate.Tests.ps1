<#
This file exists to combine simple user input (Invoke-Vester), simple
user test authoring (*.Vester.ps1), and properly scoped inventory objects
into a single test session that loops through all necessary combinations.

It is called by Invoke-Vester via the Invoke-Pester command.

https://wahlnetwork.github.io/Vester
#>

# Accept -WhatIf input from Invoke-Vester
[CmdletBinding(SupportsShouldProcess = $true,
               ConfirmImpact = 'Medium')]
Param(
    # The $cfg hashtable from a single config file
    [object]$Cfg,

    # Array of paths for tests to run against this config file
    [object]$TestFiles,

    # Pass through the user's preference to fix differences or not
    [switch]$Remediate
)

# Gracefully handle FileSystemInfo/Vester.Test objects
# Get-Item, Get-ChildItem, Get-VesterTest (without -Simple parameter)
If ($TestFiles.FullName) {
    $TestFiles = $TestFiles.FullName
}

# Gets the scope, the objects for the scope and their requested test files
$Scopes = Split-Path (Split-Path $TestFiles -Parent) -Leaf | Select -Unique
$Final = @()
$InventoryList = @()
$Datacenter = Get-Datacenter -Name $cfg.scope.datacenter -Server $cfg.vcenter.vc
foreach($Scope in $Scopes)
{
    Write-Verbose "Processing $Scope"
    Remove-Variable InventoryList -ErrorAction SilentlyContinue # Makes sure the variable is always fresh
    # Use $Scope (parent folder) to get the correct objects to test against
    # If changing values here, update the "$Scope -notmatch" test below as well
    $InventoryList = switch ($Scope) {
        'vCenter'    {$global:DefaultVIServer | where-object {$_.name -like "$($cfg.vcenter.vc)"}}
        'Datacenter' {$Datacenter}
        'Cluster'    {$Datacenter | Get-Cluster -Name $cfg.scope.cluster}
        'DSCluster'  {$Datacenter | Get-DatastoreCluster -Name $cfg.scope.dscluster}
        'Host'       {$Datacenter | Get-Cluster -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host}
        'VM'         {$Datacenter | Get-Cluster -Name $cfg.scope.cluster | Get-VM -Name $cfg.scope.vm}
        'Network'    {$Datacenter | Get-VDSwitch -Name $cfg.scope.vds}
    }

    $ScopeObj = [pscustomobject] @{
        'Scope'         = $Scope
        'InventoryList' = $InventoryList
        'TestFiles'     = $TestFiles | Where-Object { (Split-Path (Split-Path $_ -Parent) -Leaf) -eq $Scope }
    }
    if (($ScopeObj.InventoryList -ne $NULL) -and ($ScopeObj.TestFiles -ne $NULL)){
        $Final += $ScopeObj
    }
}

# Loops through each Scope
foreach($Scope in $Final.Scope)
{
    # Pulling the inventory and test files for this scope
    $Inventory = ($Final | Where-Object { $_.Scope -eq $Scope }).InventoryList
    $Tests = ($Final | Where-Object { $_.Scope -eq $Scope }).TestFiles

    # The parent folder must be one of these names, to help with $Object scoping below
    # If adding here, also needs to be added to the switch below
    If ('vCenter|Datacenter|Cluster|DSCluster|Host|VM|Network' -notmatch $Scope) {
        Write-Warning "Skipping test $TestName. Use -Verbose for more details"
        Write-Verbose 'Test files should be in a folder with one of the following names:'
        Write-Verbose 'vCenter / Datacenter / Cluster / DSCluster / Host / VM / Network'
        Write-Verbose 'This helps Vester determine which inventory object(s) to use during the test.'
        # Use continue to skip this test and go to the next loop iteration
        continue
    }

    # Runs through each test file on the below objects in the current scope
    foreach($Test in $Tests)
    {
        Write-Verbose "Processing test file $Test"
        $TestName = Split-Path $Test -Leaf

        Describe -Name "$Scope Configuration: $TestName" -Fixture {
			# Pull in $Title/$Description/$Desired/$Type/$Actual/$Fix from the test file
			. $Test

			# Pump the brakes if the config value is $null
			If ($Desired -eq $null) {
				Write-Verbose "Due to null config value, skipping test $TestName"
				# Use continue to skip this test and go to the next loop iteration
				continue
			}

			# Loops through each object in the inventory list for the specific scope.
			# It runs one test at a time against each $Object and moves onto the next test.
			foreach($Object in $Inventory)
			{
				It -Name "$Scope $($Object.Name) - $Title" -Test {
					Try {
						# "& $Actual" is running the first script block to compare to $Desired
						# The comparison should be empty
						# (meaning everything is the same, as expected)
						$Result = (& $Actual -as $Type)
						Compare-Object -ReferenceObject $Desired -DifferenceObject $Result |
							Should BeNullOrEmpty
					} Catch {
						# If the comparison found something different,
						# Then check if we're going to fix it
						If ($Remediate) {
							Write-Warning -Message $_
							# -WhatIf support wraps the command that would change values
							If ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - $Scope '$Object'", "Set '$Title' value to '$Desired'")) {
								Write-Warning -Message "Remediating $Object"
								# Execute the $Fix script block
								& $Fix
							}
						} Else {
							# -Remediate is not active, so just report the error
							$Message = @(
                                "Desired:   [$($Desired.gettype())] $Desired"
                                "Actual:    [$($Result.gettype())] $Result"
                                "Synopsis:  $Description"
                                "Link:      https://wahlnetwork.github.io/Vester/reference/tests/$Scope/$($Title.replace(' ','-').replace(':','')).html"
                                "Test File: $Test"
                            ) -join "`n"
                            Throw $Message
						}
					} #Try/Catch
				} #It
            } #Foreach Inventory                    
        }#Describe
    }#Foreach Tests
}#Foreach Final.Scope