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

function ConvertPSObjectToHashtable { 
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

	 process {
		if ($InputObject -is [psobject]){
			$hash = @{}
			foreach ($property in $InputObject.PSObject.Properties){
				$hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
			}
			$hash
		}
		else{
			$InputObject
		}
	 } 
}

function Compare-Hashtable {
<#
.SYNOPSIS
Compare two Hashtable and returns an array of differences.

.DESCRIPTION
The Compare-Hashtable function computes differences between two Hashtables. Results are returned as
an array of objects with the properties: "key" (the name of the key that caused a difference), 
"side" (one of "<=", "!=" or "=>"), "lvalue" an "rvalue" (resp. the left and right value 
associated with the key).

.PARAMETER left 
The left hand side Hashtable to compare.

.PARAMETER right 
The right hand side Hashtable to compare.

.EXAMPLE

Returns a difference for ("3 <="), c (3 "!=" 4) and e ("=>" 5).

Compare-Hashtable @{ a = 1; b = 2; c = 3 } @{ b = 2; c = 4; e = 5}

.EXAMPLE 

Returns a difference for a ("3 <="), c (3 "!=" 4), e ("=>" 5) and g (6 "<=").

$left = @{ a = 1; b = 2; c = 3; f = $Null; g = 6 }
$right = @{ b = 2; c = 4; e = 5; f = $Null; g = $Null }

Compare-Hashtable $left $right

#>	
[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable]$Left,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Right		
	)
	
	function New-Result($Key, $LValue, $Side, $RValue) {
		New-Object -Type PSObject -Property @{
					key    = $Key
					lvalue = $LValue
					rvalue = $RValue
					side   = $Side
			}
	}
	[Object[]]$Results = $Left.Keys | % {
		if ($Left.ContainsKey($_) -and !$Right.ContainsKey($_)) {
			New-Result $_ $Left[$_] "<=" $Null
		} else {
			if ($Left[$_] -is [hashtable] -and $Right[$_] -is [hashtable] ) {
				Compare-Hashtable $Left[$_] $Right[$_]
			}
			else {
				$LValue, $RValue = $Left[$_], $Right[$_]
				if ($LValue -ne $RValue) {
					New-Result $_ $LValue "!=" $RValue
				}
			}
		}
	}
	$Results += $Right.Keys | % {
		if (!$Left.ContainsKey($_) -and $Right.ContainsKey($_)) {
			New-Result $_ $Null "=>" $Right[$_]
		} 
	}
	if ($Results -ne $null) { $Results }
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
        'Cluster'    {Get-Cluster -Location $Datacenter -Name $cfg.scope.cluster}
        'DSCluster'  {$Datacenter | Get-DatastoreCluster -Name $cfg.scope.dscluster}
        'Host'       {Get-Cluster -Location $Datacenter -Name $cfg.scope.cluster | Get-VMHost -Name $cfg.scope.host}
        'VM'         {Get-Cluster -Location $Datacenter -Name $cfg.scope.cluster | Get-VM -Name $cfg.scope.vm}
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

        # Loops through each object in the inventory list for the specific scope.
        # It runs one test at a time against each $Object and moves onto the next test.
        ForEach($Object in $Inventory)
        {
            Write-Verbose "Processing test file $Test"
            $TestName = Split-Path $Test -Leaf

            Describe -Name "$Scope Configuration: $TestName" -Fixture {
                # Pull in $Title/$Description/$Desired/$Type/$Actual/$Fix from the test file
                . $Test

                # If multiple tests
                # Added in a check for $NULL and "" as you can't run a method (gettype()) on a $Null valued expression
                # This is checking for an object that is a PSCustomobject, which shouldnt be null.
                If(($Desired -ne $NULL) -and ($Desired -ne "") -and ($Desired.GetType().Name -eq "PSCustomObject")) {
                    # Gathers the the actual and desired values
                    # Formats the hashtable as a PSCustomObject
                    # As a side note: The ActualObjects Type is always the correct object type
                    # ConvertFrom-Json does not preserve things like 'int64'
                    # Converts to hashtable
                    $Results = (& $Actual)

                    # Converts $Desired to a hashtable as it needs to be a hashtable to be compared
                    # $ht2 = @{}
                    # $Desired.psobject.properties | Foreach { $ht2[$_.Name] = $_.Value }
                    # $Desired = $ht2
					$Desired = $Desired | ConvertPSObjectToHashtable

                    It -Name "$Scope $($Object.Name) - $Title" -Test {
                        Try {
                            $Mishaps = Compare-HashTable -Left $Desired -Right $Results
                            $Mishaps | Should BeNullOrEmpty
                        } Catch {    
                            # If the comparison found something different,
                            # Then check if we're going to fix it
                            If($Remediate) {
                                Write-Warning -Message $_
                                # -WhatIf support wraps the command that would change values
                                If($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - $Scope '$Object'", "Set '$Title' value to '$Desired'"))
                                {
                                    Write-Warning -Message "Remediating $Object"
                                    # Execute the $Fix script block
                                    & $Fix
                                }
                            } Else {
                                # -Remediate is not active, so just report the error
                                ### Changed it to write-error so it didnt terminate the above foreach loop
                                #Write-Error "$($_.Exception.Message)" -ErrorAction Stop
                                Write-Error "$($_.Exception.Message)`n$($Mishaps | Convertto-json)" -ErrorAction "Stop"
                            }
                        } # Try/Catch
                    } # It
                } # If $Desired -eq PSCustomobject
                # Else it is a normal single value test
                Else
                {
                    It -Name "$Scope $($Object.Name) - $Title" -Test {                     
                        Try {
                            # Checks for $NULLs
                            If($Desired -eq $NULL) {
                                Write-Verbose "Making sure `$Null is still `$Null"
                                ($Desired -eq (& $Actual -as $Type)) -or ("" -eq (& $Actual -as $Type)) | Should Be $TRUE
                            } Else {
                                Compare-Object -ReferenceObject $Desired -DifferenceObject (& $Actual -as $Type) | Should BeNullOrEmpty
                            } 
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
                } #If/Else $Desired.GetType().Name -eq "PSCustomObject"
            } #Foreach Inventory                    
        }#Describe
    }#Foreach Tests
}#Foreach Final.Scope