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
    Using the default config file at \Configs\Config.ps1, Vester will run
    all *.Tests.ps1 files found inside of the current location, recursively.
    Verbose output will be displayed on the screen.
    It outputs a report of all passed and failed tests.

    .EXAMPLE
    Invoke-Vester -Script C:\Tests\ -Config C:\Tests\Config.ps1
    Vester runs all *.Tests.ps1 files found underneath the C:\Tests directory,
    and compares values to the config file in the same location.
    It outputs a report of all passed and failed tests.

    .EXAMPLE
    $DNS = Get-ChildItem -Path Z:\ -Filter *dns* -File -Recurse
    PS C:\>Get-ChildItem -Path Z:\ -Filter *config* -File | Invoke-Vester -Script $DNS
    Get all files below Z:\ with 'dns' in the name and store in variable $DNS.
    Then, get all files named like 'config' and pipe them into the -Config parameter.
    Each config file piped in will run through all $DNS tests found.

    .EXAMPLE
    Invoke-Vester -Script .\Tests\VM -Remediate -WhatIf
    Run all test files in the .\Tests\VM path below the current location.
    For all tests that fail against the values in \Configs\Config.ps1,
    -Remediate attempts to immediately fix them to match your defined config.
    -WhatIf prevents remediation, and instead reports what would have changed.

    .EXAMPLE
    Invoke-Vester -Config .\Config-Dev.ps1 -Remediate
    Run all test files in the current location, and compare values to those
    defined within the Config-Dev.ps1 file at the current location.
    For all failed tests, -Remediate attempts to immediately fix them
    to match the defined values.

    .INPUTS
    [System.Object]
    Accepts piped input via property name "FullName" (designed for Get-Item/Get-ChildItem)

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
        # Defaults to Vester\Configs\Config.ps1
        [Parameter(ValueFromPipeline = $True,
                   ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({ForEach ($Path in $_) {Test-Path $Path -PathType 'Leaf'} })]
        [Alias('FullName')]
        [object[]]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json",

        # Define the file/folder of test file(s) to call
        # Defaults to the current location
        [Alias('Path','Script')]
        [object[]]$Test = '.',

        # Optionally fix all config drift that is discovered
        # Defaults to false (disabled)
        [switch]$Remediate = $false
    )

    BEGIN {
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
        }
    }

    PROCESS {
        ForEach ($ConfigFile in $Config) {

            # Load the defined $cfg values to test
            Write-Verbose -Message "Processing Config file $ConfigFile"
            $cfg = Get-Content $ConfigFile | ConvertFrom-Json

            If (-not $cfg) {
                throw "Valid config file not found at path '$ConfigFile'. Exiting"
            }

            # Check for already open session to desired vCenter server
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
                $VIServer = $global:DefaultVIServers | where-Object {$_.Name -match $cfg.vcenter.vc}
            }
            Write-Verbose "Processing against vCenter server '$($cfg.vcenter.vc)'"

            ForEach ($Path in $TestFiles) {
                Write-Verbose "Processing test file $Path"
                $Scope = (Split-Path $Path -Parent) -replace '^.*\\',''
                # Pass the specified parameters down to the testing template
                Invoke-VesterTest -Test $Path -Scope $Scope -Cfg $cfg -Remediate:$Remediate
            } #ForEach Path

        } #ForEach Config
    } # Process

    END {
    }
} # function
