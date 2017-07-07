function New-VesterConfig {
    <#
    .SYNOPSIS
    Generates a Vester config file from settings in your existing VMware environment.

    .DESCRIPTION
    New-VesterConfig is designed to be a quick way to get started with Vester.

    Vester needs one config file for each vCenter server it interacts with. To
    help speed up this one-time creation process, New-VesterConfig uses PowerCLI
    to pull current values from your environment to store in the config file.
    
    You'll be prompted with the list of Clusters/Hosts/VMs/etc. discovered, and
    asked to choose one of each type to use as a baseline; i.e. "all my other
    hosts should be configured like this one." Those values are displayed
    interactively, and you can manually edit them as desired.

    Optionally, advanced users can use the -Quiet parameter. This suppresses
    all host output and prompts. Instead, values are pulled from the first
    Cluster/Host/VM/etc. found alphabetically. Manual review afterward of the
    config file is strongly encouraged if using the -Quiet parameter.

    It outputs a single Config.json file at \Vester\Configs, which may require
    admin rights. Optionally, you can use the -OutputFolder parameter to
    specify a different folder to store the Config.json file.

    .EXAMPLE
    New-VesterConfig
    Ensures that you are connected to only one vCenter server.
    Based on all Vester test files found in '\Vester\Tests', the command
    discovers values from your environment and displays them, occasionally
    prompting for a selection of which cluster/host/etc. to use.
    Outputs a new Vester config file to '\Vester\Configs\Config.json',
    which may require admin rights.

    .EXAMPLE
    New-VesterConfig -Quiet -OutputFolder "$env:USERPROFILE\Desktop"
    -Quiet suppresses all host output and prompts, instead pulling values
    from the first cluster/host/etc. found alphabetically.
    Upon completion, Config.json will be created on your Desktop.

    .NOTES
    This command relies on the Pester and PowerCLI modules for testing.

    "Get-Help about_Vester" for more information.

    .LINK
    https://wahlnetwork.github.io/Vester

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding()]
    param (
        # Select a folder to create a new Config.json file inside
        [ValidateScript({Test-Path $_ -PathType Container})]
        [object]$OutputFolder = "$(Split-Path -Parent $PSScriptRoot)\Configs",

        # Suppress all prompts and Write-Host. Create the config file
        # with the values of the first Cluster/Host/VM/etc. found.
        [switch]$Quiet
    )

    # Must have only one vCenter connection open
    # Potential future work: loop through all vCenter connections
    If ($DefaultVIServers.Count -lt 1) {
        Write-Warning 'Please connect to vCenter before running this command.'
        throw 'A single connection with Connect-VIServer is required.'
    } ElseIf ($DefaultVIServers.Count -gt 1) {
        Write-Warning 'Vester config files are designed to be unique to each vCenter server.'
        Write-Warning 'Please connect to only one vCenter before running this command.'
        Write-Warning "Current connections:  $($DefaultVIServers -join ' / ')"
        throw 'A single connection with Connect-VIServer is required.'
    }
    Write-Verbose "vCenter: $($DefaultVIServers.Name)"

    # TODO: Make this a param? Or keep hardcoded?
    Write-Verbose "Assembling Vester files within $(Split-Path -Parent $PSScriptRoot)\Tests\"
    $GetVesterTest = "$(Split-Path -Parent $PSScriptRoot)\Tests\" | Get-VesterTest
    # Appending to a list is faster than rebuilding an array
    $VesterTestSuite = New-Object 'System.Collections.Generic.List[PSCustomObject]'

    # For each *.Vester.ps1 file found,
    $GetVesterTest | ForEach-Object {
        # Do the necessary Split-Path calls once and save them for later
        $v = [PSCustomObject]@{
            Full   = $_
            Parent = Split-Path (Split-Path $_ -Parent) -Leaf
            Leaf   = Split-Path $_ -Leaf
        }
        $VesterTestSuite.Add($v)
    }

    If (-not $Quiet) {
        # Introduce and inform of $null
        Write-Host 'Vester will now start pulling values from your vCenter server, '-NoNewline
        Write-Host "$($DefaultVIServers.Name)" -ForegroundColor Yellow
        Write-Host 'After each section, you will be asked if you want to edit any values.'
    }

    $config = [ordered]@{}
    $config.vcenter = @{vc = $DefaultVIServers.Name}

#region scope
    # Set the section's config, and then display it for review
    $config.scope = [ordered]@{
        datacenter = '*'
        cluster    = '*'
        dscluster  = '*'
        host       = '*'
        vm         = '*'
        vds        = '*'
    }

    If (-not $Quiet) {
        # Explain each setting
        Write-Host "`n  ### Inventory Scopes" -ForegroundColor Green
        Write-Host "This dictates the scope of your vSphere environment that will be tested by Pester."
        Write-Host "Use string values. Wildcards are accepted."
        Write-Host "datacenter = [string] vSphere datacenter name(s)"
        Write-Host "cluster    = [string] vSphere cluster name(s)"
        Write-Host "dscluster  = [string] vSphere datastore cluster name(s)"
        Write-Host "host       = [string] ESXi host name(s)"
        Write-Host "vm         = [string] Virtual machine name(s)"
        Write-Host "vds        = [string] vSphere Distributed Switch (VDS) name(s)"

        # Empty Write-Host just to insert extra line breaks where desired
        Write-Host ''
        $config.scope

        If ((Read-HostColor "`nWould you like to change any of those values? Y/N [N]") -like 'y*') {
            Write-Host "`nFor all values, entering nothing will keep the default * to check all objects of that category.`n"

            [string]$ManualDatacenter = Read-HostColor 'datacenter = Filter the following command: Get-Datacenter -Name YOURINPUTHERE -Server $vCenter'
            [string]$ManualCluster    = Read-HostColor 'cluster = Filter the following command: $Datacenter | Get-Cluster -Name YOURINPUTHERE'
            [string]$ManualDSCluster  = Read-HostColor 'dscluster = Filter the following command: $Datacenter | Get-DatastoreCluster -Name YOURINPUTHERE'
            [string]$ManualHost       = Read-HostColor 'host = Filter the following command: $Cluster | Get-VMHost -Name YOURINPUTHERE'
            [string]$ManualVM         = Read-HostColor 'vm = Filter the following command: $Cluster | Get-VM -Name YOURINPUTHERE'
            [string]$ManualVDS        = Read-HostColor 'vds = Filter the following command: $Datacenter | Get-VDSwitch -Name YOURINPUTHERE'

            $config.scope.datacenter = If ($ManualDatacenter -eq '') {'*'} Else {$ManualDatacenter}
            $config.scope.cluster    = If ($ManualCluster -eq '')    {'*'} Else {$ManualCluster}
            $config.scope.dscluster  = If ($ManualDSCluster -eq '')  {'*'} Else {$ManualDSCluster}
            $config.scope.host       = If ($ManualHost -eq '')       {'*'} Else {$ManualHost}
            $config.scope.vm         = If ($ManualVM -eq '')         {'*'} Else {$ManualVM}
            $config.scope.vds        = If ($ManualVDS -eq '')        {'*'} Else {$ManualVDS}
        }
    } #if not $Quiet

    Write-Verbose "Gathering inventory objects from $($DefaultVIServers.Name)"
    $vCenter    = $DefaultVIServers.Name
    $Datacenter = Get-Datacenter -Name $config.scope.datacenter -Server $vCenter
    $Cluster    = $Datacenter | Get-Cluster -Name $config.scope.cluster
    $DSCluster  = $Datacenter | Get-DatastoreCluster -Name $config.scope.dscluster
    $VMHost     = $Cluster | Get-VMHost -Name $config.scope.host
    $VM         = $Cluster | Get-VM -Name $config.scope.vm
    # Secondary modules...PowerCLI doesn't do implicit module loading as of PCLI 6.5
    # This is all the effort I'm willing to put into working around that right now
    Try {
        $Network = $Datacenter | Get-VDSwitch -Name $config.scope.vds -ErrorAction Stop
    } Catch {
        Write-Warning 'Get-VDSwitch failed. Have you manually imported module "VMware.VimAutomation.Vds"?'
    }

    If ($Quiet) {
        $Datacenter = If ($Datacenter) {$Datacenter[0]}
        $Cluster    = If ($Cluster)    {$Cluster[0]}
        $DSCluster  = If ($DSCluster)  {$DSCluster[0]}
        $VMHost     = If ($VMHost)     {$VMHost[0]}
        $VM         = If ($VM)         {$VM[0]}
        $Network    = If ($Network)    {$Network[0]}
    } Else {
        $Datacenter = If ($Datacenter) {Select-InventoryObject $Datacenter 'Datacenter'}
        $Cluster    = If ($Cluster)    {Select-InventoryObject $Cluster 'Cluster'}
        $DSCluster  = If ($DSCluster)  {Select-InventoryObject $DSCluster 'DSCluster'}
        $VMHost     = If ($VMHost)     {Select-InventoryObject $VMHost 'Host'}
        $VM         = If ($VM)         {Select-InventoryObject $VM 'VM'}
        $Network    = If ($Network)    {Select-InventoryObject $Network 'Network'}
    }
#endregion
        
    $ScopeList = ($VesterTestSuite | Select-Object -Property Parent -Unique).Parent
    Write-Verbose "Scopes supplied by test files: $($ScopeList -join ' | ')"
    
    # Not used; called below to help with manual user overrides of values
    # That block is also commented out, awaiting potential future improvements
    # $TestHistory = New-Object 'System.Collections.Generic.List[PSCustomObject]'

    # Group tests by their scope
    ForEach ($Scope in $ScopeList) {
        Write-Verbose "Processing all tests for scope $Scope"

        # Loop through each test file applicable in the current scope
        # Couldn't resist calling each file a Vest. Sorry, everyone
        ForEach ($Vest in $VesterTestSuite | Where-Object Parent -eq $Scope) {
            Write-Verbose "Processing test file $($Vest.Leaf)"
            
            # Import all variables from the current .Vester.ps1 file
            . $Vest.Full

            $Object = switch ($Scope) {
                'vCenter'    {$vCenter}
                'Datacenter' {$Datacenter}
                'Cluster'    {$Cluster}
                'DSCluster'  {$DSCluster}
                'Host'       {$VMHost}
                'VM'         {$VM}
                'Network'    {$Network}
                # If not scoped properly, don't know what object to check
                Default      {$null}
            }

            # TODO: Should probably offload this to a private function
            $CfgLine = (Select-String -Path $Vest.Full -Pattern '\$cfg') -replace '.*\:[0-9]+\:',''
            $CfgLine -match '.*\$cfg\.([a-z]+)\.([a-z]+)$' | Out-Null

            # Run the $Actual script block, storing the result in $Result
            If ($Object -and ($Result = & $Actual) -ne $null) {
                # Call module private function Set-VesterConfigValue to add the entry
                Set-VesterConfigValue -Value ($Result -as $Type)
            } Else {
                # Inventory $Object doesn't exist, or $Actual returned nothing
                # Populate with null value; Invoke-Vester will skip this test
                Set-VesterConfigValue -Value $null
            } #if $Object and $Result

            <# ### This works, but not currently used (see commented block below)
            If ($config.$($Matches[1]).Keys -contains $($Matches[2]) -and -not $Quiet) {
                # Record test/value correlation, if user wants to manually edit
                $h = [PSCustomObject]@{
                    Full = $Vest.Full
                    Leaf = $Vest.Leaf
                    CfgValue = "$($Matches[1]).$($Matches[2])"
                }
                $TestHistory.Add($h)
            }
            #>
        } #foreach $Vest

        # If any values were populated in this scope, and the -Quiet flag is not active,
        # Display all values for this scope and ask about manual overrides
        If ($config.$Scope -and -not $Quiet) {
            # Empty Write-Host just to insert extra line breaks where desired
            Write-Host ''
            Write-Host '  # Config values for scope ' -NoNewline
            Write-Host "$Scope" -ForegroundColor Green
            $Sorted = $config.$Scope.GetEnumerator() | Sort-Object Name
            $Sorted
            $config.$Scope = [ordered]@{}
            $Sorted | Foreach-Object { $config.$Scope.Add($_.Name, $_.Value) }            

            <# ###
            # Users still need to manually edit the .json file if changes are desired
            # The code block below works, but needs much more validation on entry
            # For example, entering text into a "string[]" type does the following:
                # The apostrophe, a common string wrapper, ends up in the json file as \u0027
                # Not sure how to enter multiple string values (like muliple DNS servers)

            If ((Read-HostColor 'Would you like to change any of these values? Y/N [N]') -like 'y*') {
                Write-Host "`nIf there are any values you never want to test, enter " -NoNewline
                Write-Host '$null' -ForegroundColor Red -NoNewline
                Write-Host " to skip those tests.`n"
                # TODO: ^ Entering $null still good instructions?

                ForEach ($CfgLine in $config.$Scope.GetEnumerator() | Sort Name) {
                    $TestHistory | Where CfgValue -eq "$Scope.$($CfgLine.Name)" | ForEach-Object {
                        . $_.Full

                        Write-Host "$($_.Leaf) : $Title"
                        Write-Host $Description
                        Write-Host "[$Type]$($CfgLine.Name) = $($CfgLine.Value)"

                        If ((Read-HostColor 'Would you like to change this value? Y/N [N]') -like 'y*') {
                            $UserEnteredValue = Read-HostColor "Enter the new value of type '$Type'"
                            If ($UserEnteredValue -eq $null) {
                                $NewValue = $null
                            } Else {
                                $NewValue = $UserEnteredValue -as $Type
                            }
                            Write-Verbose "Setting $($Scope.ToLower()).$($CfgLine.Name) = $UserEnteredValue"
                            $config.$Scope.($CfgLine.Name) = $UserEnteredValue
                        } #if change single value
                    } #foreach $TestHistory
                } #foreach $CfgLine
            } #if change any value
            #>

        } #if $config.$Scope
    } #foreach $Scope

    Write-Verbose "Creating config file at $OutputFolder\Config.json"
    Try {
        $config | ConvertTo-Json | Out-File $OutputFolder\Config.json -ErrorAction Stop
        Write-Host "`nConfig file created at " -ForegroundColor Green -NoNewline
        Write-Host "$OutputFolder\Config.json"
        Write-Host 'Edit the file manually to change any displayed values.'
    } Catch {
        Write-Warning "`nFailed to create config file at $OutputFolder\Config.json"
        Write-Warning 'Have you tried running PowerShell as an administrator?'
    }
}
