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
    Using the default config file at \Vester\Configs\Config.json,
    Vester will run all included tests inside of \Vester\Tests\.
    Verbose output will be displayed on the screen.
    It outputs a report to the host of all passed and failed tests.

    .EXAMPLE
    Invoke-Vester -Config C:\Tests\Config.json -Test C:\Tests\
    Vester runs all *.Vester.ps1 files found underneath the C:\Tests\ directory,
    and compares values to the config file in the same location.
    It outputs a report to the host of all passed and failed tests.

    .EXAMPLE
    $DNS = Get-VesterTest -Path Z:\ -Name *dns*
    PS C:\>(Get-ChildItem -Path Z:\ -Filter *.json).FullName | Invoke-Vester -Test $DNS

    Get all Vester tests at Z:\ with 'dns' in the name; store in variable $DNS.
    Then, pipe all *.json files at the root of Z: into the -Config parameter.
    Each config file piped in will run through all $DNS tests found.

    .EXAMPLE
    Invoke-Vester -Test (Get-VesterTest -Scope VM) -Remediate -WhatIf
    Run Vester with all VM tests included with the module.
    For all tests that fail against the values in \Configs\Config.json,
    -Remediate attempts to immediately fix them to match your defined config.
    -WhatIf prevents remediation, and instead reports what would have changed.

    .EXAMPLE
    Invoke-Vester -Config .\Config-Dev.json -Remediate
    Run all \Vester\Tests\ files, and compare values to those defined within
    the Config-Dev.json file at the current location.
    For all failed tests, -Remediate attempts to immediately correct your
    infrastructure to match the previously defined values in your config file.

    .EXAMPLE
    Invoke-Vester -XMLOutputFile .\vester.xml
    Runs Vester with the default config and test files.
    Uses Pester to send test results in NUnitXML format to vester.xml
    at your current folder location.
    Useful to supply to a report generator for HTML reports.

    .EXAMPLE
    Invoke-Vester -ShowFailedOnly
    Run Vester but limit console output to only failed tests.
    Uses the Pester "-Show Failed,Summary" option.
    Requires Pester module version 3.4.1 or newer.

    .INPUTS
    [System.Object]
    Accepts piped input (optional multiple objects) for parameter -Config

    .NOTES
    This command relies on the Pester and PowerCLI modules for testing.

    "Get-Help about_Vester" for more information.

    .LINK
    https://wahlnetwork.github.io/Vester

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding(SupportsShouldProcess = $true,
                   ConfirmImpact = 'Medium')]
    # ^ that passes -WhatIf through to other tests
    param (
        # Optionally define a different config file to use
        # Defaults to \Vester\Configs\Config.json
        [Parameter(ValueFromPipeline = $True,
                   ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({
            If ($_.FullName) {Test-Path $_.FullName}
            Else {Test-Path $_}
        })]
        [Alias('FullName')]
        [object[]]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json",

        # Optionally define the file/folder of test file(s) to call
        # Defaults to \Vester\Tests\, grabbing all tests recursively
        # All test files must be named *.Vester.ps1
        [ValidateScript({
            If ($_.FullName) {Test-Path $_.FullName}
            Else {Test-Path $_}
        })]
        [Alias('Path','Script')]
        [object[]]$Test = (Get-VesterTest -Simple),

        # Optionally fix all config drift that is discovered
        # Defaults to false (disabled)
        [switch]$Remediate = $false,

        # Optionally save Pester output in NUnitXML format to a specified path
        # Specifying a path automatically triggers Pester in NUnitXML mode
        [ValidateScript({Test-Path (Split-Path $_ -Parent)})]
        [object]$XMLOutputFile,

        # Pester >= 3.4.1 added a -Show parameter for filtering the console output
        # Provide a simple switch that adds -Show Failed,Summary to Invoke-Pester
        [switch]$ShowFailedOnly = $false,

        # Optionally returns the Pester result as an object containing the information about the whole test run, and each test
        # Defaults to false (disabled)
        [switch]$PassThru = $false
    )

    PROCESS {
        # -Test should accept directories and objects
        If ($Test[0] -notlike '*.Vester.ps1') {
            If ($Test[0].FullName) {
                # Strip Get-Item/Get-ChildItem/Get-VesterTest object to path only
                $Test = $Test.FullName
            } Else {
                # This is a directory. Get the Vester tests here
                $Test = $Test | Get-VesterTest -Simple
            }
        }

        ForEach ($ConfigFile in $Config) {
            # Gracefully handle Get-Item/Get-ChildItem
            # Always pass thru Get-Item, to support cross-platform path conventions
            If(Test-Path $ConfigFile) {
                $ConfigFile = (Get-Item $ConfigFile).FullName
            } else {
                throw "Config file specified does not exist: '$ConfigFile'. Exiting"
            }

            Write-Verbose -Message "Processing Config file $ConfigFile"

            # Load the defined $cfg values to test
            # -Raw needed for PS v3/v4
            $cfg = Get-Content $ConfigFile -Raw | ConvertFrom-Json

            If (-not $cfg) {
                throw "Valid config data not found at path '$ConfigFile'. Exiting"
            }

            # Check for established session to desired vCenter server
            If ($cfg.vcenter.vc -notin $global:DefaultVIServers.Name) {
                Try {
                    # Attempt connection to vCenter; prompts for credentials if needed
                    Write-Verbose "No active connection found to configured vCenter '$($cfg.vcenter.vc)'. Connecting"
                    $VIServer = Connect-VIServer -Server $cfg.vcenter.vc -ErrorAction Stop
                } Catch {
                    # If unable to connect, stop
                    throw "Unable to connect to configured vCenter '$($cfg.vcenter.vc)'. Exiting"
                }
            } Else {
                $VIServer = $global:DefaultVIServers | Where-Object {$_.Name -match $cfg.vcenter.vc}
            }
            Write-Verbose "Processing against vCenter server '$($cfg.vcenter.vc)'"
            #Build Pester Parameter Hashtable to splat
            $Pester_Params = @{
                Script = @{
                    Path = (Get-Item "$(Split-Path -Parent $PSScriptRoot)\Private\Template\VesterTemplate.Tests.ps1").FullName
                    Parameters = @{
                        Cfg       = $cfg
                        TestFiles = $Test
                        Remediate = $Remediate
                    }#Parameters
                }#Script
            }#Pester_Params

            If ($XMLOutputFile) {
                $Pester_Params += @{
                   OutputFormat = "NUnitXml"
                   OutputFile = $XMLOutputFile

                }#Pester_Params
            }

            If ($ShowFailedOnly) {
                $Pester_Params += @{
                    Show = "Failed,Summary"
                }#Pester_Params
            }
            # Call Invoke-Pester based on the parameters supplied
            # Runs VesterTemplate.Tests.ps1, which constructs the .Vester.ps1 test files
            Invoke-Pester @Pester_Params -PassThru:$PassThru
            # In case multiple config files were provided and some aren't valid
            $cfg = $null
        } #ForEach Config
    } #Process
} #function
