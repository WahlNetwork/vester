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
    Get-ChildItem -Path Z:\ -Filter *dns* -File -Recurse | Invoke-Vester
    Use Get-ChildItem to get all files below Z:\ with 'dns' in the name.
    Pipe those files into Invoke-Vester to run them as tests.

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
        # Define the file/folder of test file(s) to call
        # Defaults to the current location
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Path','FullName')]
        [object[]]$Script = '.',
        # Aliasing FullName enables easy pipe from Get-ChildItem

        # Optionally define a different config file to use
        # Defaults to Vester\Configs\Config.ps1
        # Currently only supports one Config file at a time
        [ValidateScript({Foreach ($Path in $_) {Test-Path $Path -PathType 'Leaf'} })] 
        [object[]]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.ps1",

        # Optionally fix all config drift that is discovered
        # Defaults to false (disabled)
        [switch]$Remediate = $false
    )

    BEGIN {

    } # Begin

    PROCESS {
        Foreach ($ConfigFile in $Config) {
            # Load the defined $cfg values to test
            Write-Verbose -Message "Processing Config file $ConfigFile"
            . $ConfigFile

            If (-not $cfg) {
                throw "Valid config file not found at path '$ConfigFile'. Exiting"
            }

            # Check for already open session to desired vCenter server
            If ($cfg.vcenter.vc -notin $global:DefaultVIServers.Name) {
                Try {
                    # Attempt connection to vCenter, prompting for credentials
                    Write-Verbose "No active connection found to configured vCenter '$($cfg.vcenter.vc)'. Connecting"
                    Connect-VIServer -Server $cfg.vcenter.vc -Credential (Get-Credential) -ErrorAction Stop
                } Catch {
                    # If unable to connect, stop
                    throw "Unable to connect to configured vCenter '$($cfg.vcenter.vc)'. Exiting"
                }
            }
            Write-Verbose "Processing against vCenter server '$($cfg.vcenter.vc)'"
            # Need to ForEach if multiple -Script locations are not piped in
            ForEach ($Path in $Script) {
                # Pester accepts Tag/Exclude being null, but each test will need $Config/$Remediate params
                Invoke-Pester -Script @{
                    Path = $Path
                    Parameters = @{
                        Config = $ConfigFile
                        Remediate = $Remediate
                    }
                } # Invoke-Pester
            } #ForEach Path
        } #Foreach Config
    } # Process

    END {
    }
} # function
