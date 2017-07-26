function Get-VesterTest {
    <#
    .SYNOPSIS
    Gather Vester test filepaths and details of each test.

    .DESCRIPTION
    Get-VesterTest looks for .Vester.ps1 files, excludes some if the -Scope
    or -Name parameters were specified, and then inspects each test file.
    File path and detailed properties about each test are returned.

    By default, all tests included with the module are inspected, and only
    three properties are displayed: Name, Scope, and Description.

    "Get-Help Get-VesterTest -Examples" for more details.

    .EXAMPLE
    Get-VesterTest -Verbose
    Displays the Name, Scope, and Description of all Vester test files
    packaged with the module.
    Verbose messages are available, if extra info is desired.

    .EXAMPLE
    Get-VesterTest | Select-Object -First 1 | Format-List *
    Returns the first Vester test found from the module.
    "Format-List *" displays all properties, instead of the default three.

    .EXAMPLE
    Get-VesterTest -Scope Cluster,vCenter
    Returns all Vester tests that apply to the "Cluster" and "vCenter" scopes.

    .EXAMPLE
    Get-VesterTest -Name 'CPU-Limits','ntp*'
    Returns tests named "CPU-Limits" and tests starting with "NTP".
    -Name is case insensitive.

    .EXAMPLE
    Get-VesterTest -Path C:\Vester\CustomTest.Vester.ps1
    -Path can be used to retrieve tests outside of the Vester module install.
    Here, it collects info from CustomTest to return.

    .EXAMPLE
    Get-VesterTest -Path C:\Vester\
    -Path can also be pointed at a directory containing custom tests.
    Get-VesterTest will search here for all .Vester.ps1 files, recursively.
    
    (Note that the immediate parent folder of all test files should have a
    name matching the test's intended scope, like "VM".)

    .INPUTS
    [System.Object]
    Accepts piped input(s) for parameter -Path.

    .OUTPUTS
    [PSCustomObject] / [Vester.Test]
    PSCustomObjects (with custom typename "Vester.Test") are returned.

    [System.String]
    If -Simple is active, only strings with each file's full path are returned.

    .NOTES
    "Get-Help about_Vester" for more information.

    .LINK
    https://wahlnetwork.github.io/Vester

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding()]
    param (
        # The file/folder path(s) to retrieve test info from.
        # If a directory, child .Vester.ps1 files are gathered recursively.
        [Parameter(ValueFromPipeline = $true)]
        [ValidateScript({
            If ($_.FullName) {Test-Path $_.FullName}
            Else {Test-Path $_}
        })]
        [object[]]$Path = "$(Split-Path -Parent $PSScriptRoot)\Tests\",

        # Return only test files belonging to the specified Vester scope(s).
        # Vester determines test file scope by the name of its parent directory.
        [ValidateSet('Cluster','DSCluster','Host','Network','vCenter','VM')]
        [string[]]$Scope = @('Cluster','DSCluster','Host','Network','vCenter','VM'),

        # Filter results by test name (e.g. "DRS-Enabled" or "*DRS*").
        # -Name parameter is not case sensitive.
        [string[]]$Name,

        # Simply return the full path of the file, instead of a rich object
        # Faster, as it does not inspect the contents of each Vester test file
        [switch]$Simple
    )

    BEGIN {
        Write-Verbose '[Get-VesterTest] Function called'

        # Using $PSBoundParameters to set variable $Get
        If (-not $PSBoundParameters.ContainsKey('Path')) {
            Write-Verbose "-Path not specified; searching default module path"
            $PSBoundParameters.Add('Path', $Path)
        }
        If (-not $PSBoundParameters.ContainsKey('Scope')) {
            Write-Verbose "-Scope not specified; including all scopes"
            $PSBoundParameters.Add('Scope', $Scope)
        }

        # Construct empty array to throw file paths of tests into
        $TestFiles = New-Object 'System.Collections.Generic.List[PSCustomObject]'
    }

    PROCESS {
        # Need to ForEach if multiple -Test locations
        ForEach ($TestPath in $Path) {
            # Gracefully handle FileSystemInfo objects (Get-Item / Get-ChildItem)
            If ($TestPath.FullName) {
                $TestPath = $TestPath.FullName
            }

            If (Test-Path $TestPath -PathType Container) {
                # If Test-Path finds a folder, get all *.Vester.ps1 files beneath it
                Write-Verbose "Discovering .Vester.ps1 files below directory '$TestPath'"
                # Leverage PSBoundParameters and splatting to pass only needed parameters
                $Get = Get-VesterChildItem @PSBoundParameters

                If ($Get) {
                    Write-Verbose "Discovered $($Get.Count) Vester test files"

                    If ($Simple) {
                        # Keep only the full file path
                        $Get.FullName | ForEach-Object {
                            $TestFiles.Add($_)
                        }
                    } Else {
                        # Extract details of each test file

                        $Get | ForEach-Object {
                            Write-Verbose "Processing Vester test file $($_.Name)"
                            $Vest = Extract-VestDetails -Object $_

                            # Add each *.Vester.ps1 file found to the array
                            $TestFiles.Add($Vest)
                        } #ForEach Get
                    }
                } Else {
                    throw "No *.Vester.ps1 files found at location '$TestPath'"
                } #If Get

                $Get = $null
            } ElseIf ($TestPath -like '*.Vester.ps1') {
                If ($Simple) {
                    # Keep only the full file path
                    $TestFiles.Add($Vest)
                } Else {
                    # Extract details of the file
                    Write-Verbose "Processing Vester test file $TestPath"

                    $Get = Get-VesterChildItem -Path $TestPath
                    $Vest = Extract-VestDetails -Object $_
                    $TestFiles.Add($Vest)
                    $Get = $null
                }
            } Else {
                # Because Vester tests have a very specific format,
                # and for future discoverability of that test if parent folder is specified,
                # prefer that tests are consciously named *.Vester.ps1
                throw "'$TestPath' does not match the *.Vester.ps1 naming convention for test files."
            } #If Test-Path
        } #ForEach -Test param entry
    } #process

    END {
        If (-not $Simple) {
            # Reduce default property set for readability
            $TypeData = @{
                TypeName = 'Vester.Test'
                DefaultDisplayPropertySet = 'Name','Scope','Description'
            }
            # Include -Force to avoid errors after the first run
            Update-TypeData @TypeData -Force
        }

        $TestFiles
    } #end
} #function
