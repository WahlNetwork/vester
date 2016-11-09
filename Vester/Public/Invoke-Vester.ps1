#Requires -Version 3

function Invoke-Vester {
    <#
    .SYNOPSIS
    Test and fix configuration drift in your VMware vSphere environment.

    .DESCRIPTION
    Invoke-Vester will run each test it finds and report on discrepancies.
    It compares actual values against the values you supply in a config file,
    and can fix them immediately if you include the -Remediate parameter.

    If you are not already connected to the vCenter server defined in the
    config file, Invoke-Vester will prompt for credentials to connect to it.

    Invoke-Vester then calls Pester to run each test file. The test files
    leverage PowerCLI to gather values for comparison/remediation.

    .EXAMPLE
    Invoke-Vester -Verbose
    Using the default config file at \Configs\Config.json, Vester will run
    all *.Vester.ps1 files found inside of the current location, recursively.
    Verbose output will be displayed on the screen.
    It outputs a report of all passed and failed tests.

    .EXAMPLE
    Invoke-Vester -Config C:\Tests\Config.json -Test C:\Tests\
    Vester runs all *.Vester.ps1 files found underneath the C:\Tests directory,
    and compares values to the config file in the same location.
    It outputs a report of all passed and failed tests.

    .EXAMPLE
    $TestsDNS = Get-ChildItem -Path Z:\ -Filter *dns* -File -Recurse
    PS C:\>(Get-ChildItem -Path Z:\ -Filter *.json).FullName | Invoke-Vester -Test $TestsDNS

    Get all files below Z:\ with 'dns' in the name; store in variable $TestsDNS.
    Then, get all *.json files and pipe them into the -Config parameter.
    Each config file piped in will run through all $TestsDNS tests found.

    .EXAMPLE
    Invoke-Vester -Test .\Tests\VM -Remediate -WhatIf
    Run *.Vester.ps1 tests in the .\Tests\VM path below the current location.
    For all tests that fail against the values in \Configs\Config.json,
    -Remediate attempts to immediately fix them to match your defined config.
    -WhatIf prevents remediation, and instead reports what would have changed.

    .EXAMPLE
    Invoke-Vester -Config .\Config-Dev.json -Remediate
    Run all \Vester\Tests files, and compare values to those defined within the
    Config-Dev.json file at the current location.
    For all failed tests, -Remediate attempts to immediately correct your
    infrastructure to match the previously defined values in your config file.

    .INPUTS
    [System.Object]
    Accepts piped input (optional multiple objects) for parameter -Config

    .NOTES
    This command relies on the Pester and PowerCLI modules for testing.

    "Get-Help about_Vester" for more information.

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding(SupportsShouldProcess = $true,
                   ConfirmImpact = 'Medium')]
    # Passes -WhatIf through to other tests
    param (
        # Optionally define a different config file to use
        # Defaults to \Vester\Configs\Config.json
        [Parameter(ValueFromPipeline = $True,
                   ValueFromPipelinebyPropertyName=$True)]
        [Alias('FullName')]
        [object[]]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json",

        # Optionally define the file/folder of test file(s) to call
        # Defaults to \Vester\Tests\, grabbing all tests recursively
        # Individual test files must be named *.Vester.ps1
        [Alias('Path','Script')]
        [object[]]$Test = "$(Split-Path -Parent $PSScriptRoot)\Tests\",

        # Optionally fix all config drift that is discovered
        # Defaults to false (disabled)
        [switch]$Remediate = $false,

        [object]$XMLOutputPath
    )

    BEGIN {
        If ((Test-Path $Config) -eq $false) {
            Write-Warning 'Config file not found. Try running New-VesterConfig with admin rights.'
            throw 'No config file provided.'
        }

        $TestFiles = New-Object 'System.Collections.Generic.List[String]'

        # Need to ForEach if multiple -Test locations
        ForEach ($TestPath in $Test) {
            # If Test-Path returns false, we're done
            If (-not (Test-Path $TestPath -PathType Any)) {
                throw "Test parameter '$TestPath' does not resolve to a path."
            # If Test-Path finds a folder, get all *.Vester.ps1 files beneath it
            } ElseIf (Test-Path $TestPath -PathType Container) {
                Write-Verbose "Discovering *.Vester.ps1 files below directory '$TestPath'."
                $GCI = (Get-ChildItem $TestPath -Recurse -Filter '*.Vester.ps1').FullName

                If ($GCI) {
                    # Add each *.Vester.ps1 file found to the array
                    $GCI | ForEach-Object {
                        $TestFiles.Add($_)
                    }
                } Else {
                    throw "No *.Vester.ps1 files found at location '$TestPath'."
                }

                $GCI = $null
            # Add the single file to the array if it matches *.Vester.ps1
            } Else {
                If ($TestPath -match '\.Vester\.ps1') {
                    $TestFiles.Add($TestPath)
                } Else {
                    # Just because Vester tests have a very specific format
                    # Prefer that tests are consciously named *.Vester.ps1
                    throw "'$TestPath' does not match the *.Vester.ps1 naming convention for test files."
                }
            }
        } #ForEach TestPath
    } #Begin

    PROCESS {
        ForEach ($ConfigFile in $Config) {

            # Load the defined $cfg values to test
            Write-Verbose -Message "Processing Config file $ConfigFile"
            $cfg = Get-Content $ConfigFile | ConvertFrom-Json

            If (-not $cfg) {
                throw "Valid config data not found at path '$ConfigFile'. Exiting"
            }

            # Check for established session to desired vCenter server
            If ($cfg.vcenter.vc -notin $global:DefaultVIServers.Name) {
                Try {
                    # Attempt connection to vCenter, prompting for credentials
                    Write-Verbose "No active connection found to configured vCenter '$($cfg.vcenter.vc)'. Connecting"
                    $VIServer = Connect-VIServer -Server $cfg.vcenter.vc -Credential (Get-Credential) -ErrorAction Stop
                } Catch {
                    # If unable to connect, stop
                    throw "Unable to connect to configured vCenter '$($cfg.vcenter.vc)'. Exiting"
                }
            } else {
                $VIServer = $global:DefaultVIServers | Where {$_.Name -match $cfg.vcenter.vc}
            }
            Write-Verbose "Processing against vCenter server '$($cfg.vcenter.vc)'"

            If ($XMLOutputPath) {
                Invoke-Pester -OutputFormat NUnitXml -OutputFile $XMLOutputPath -Script @{
                    Path = "$(Split-Path -Parent $PSScriptRoot)\Private\Template\VesterTemplate.Tests.ps1"
                    Parameters = @{
                        Cfg       = $cfg
                        TestFiles = $TestFiles
                        Remediate = $Remediate
                    }
                } # Invoke-Pester
            } Else {
                Invoke-Pester -Script @{
                    Path = "$(Split-Path -Parent $PSScriptRoot)\Private\Template\VesterTemplate.Tests.ps1"
                    Parameters = @{
                        Cfg       = $cfg
                        TestFiles = $TestFiles
                        Remediate = $Remediate
                    }
                } # Invoke-Pester
            } #If XML

            # In case multiple config files were provided and some aren't valid
            $cfg = $null
        } #ForEach Config
    } #Process
} #function
