function Get-VesterTest {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .EXAMPLE

    .INPUTS
    [System.Object]
    Accepts piped input (optional multiple objects) for parameter -Test

    .NOTES
    "Get-Help about_Vester" for more information.

    .LINK
    https://wahlnetwork.github.io/Vester

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding()]
    param (
        # The file/folder path(s) to retrieve test info from
        # If a directory, child .Vester.ps1 files are gathered recursively
        [Parameter(ValueFromPipeline = $true)]
        [object[]]$Path = "$(Split-Path -Parent $PSScriptRoot)\Tests\",

        # Return only test files belonging to the specified Vester scope(s)
        # Vester determines test file scope by the name of its parent directory
        [ValidateSet('Cluster','DSCluster','Host','Network','vCenter','VM')]
        [string[]]$Scope = @('Cluster','DSCluster','Host','Network','vCenter','VM'),

        # Filter results by test name (e.g. "DRS-Enabled" or "*DRS*")
        # -Name parameter is not case sensitive
        [string[]]$Name
    )

    BEGIN {
        # Using $PSBoundParameters to set variable $GCI
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
                Write-Verbose "Discovering *.Vester.ps1 files below directory '$TestPath'."
                # Leverage PSBoundParameters and splatting to pass only needed parameters
                $GCI = Get-VesterChildItem @PSBoundParameters

                If ($GCI) {
                    $GCI | ForEach-Object {
			            # Create $Title/$Description/$Type/$Actual/$Fix from the test file
			            . $_.FullName
                        
                        # That doesn't work to find $Desired's value, so do it here
                        $Desired = ((Select-String -Path $_.FullName -Pattern 'Desired \=').Line -split ' ')[-1]

                        $Vest = [PSCustomObject]@{
                            # Add a custom type name for this object
                            # Used with DefaultDisplayPropertySet
                            PSTypeName  = 'Vester.Test'
                            Name        = $_.Name
                            Scope       = $_.Scope
                            FullName    = $_.FullName
                            Title       = $Title
                            Description = $Description
                            Desired     = $Desired
                            Type        = $Type
                            Actual      = $Actual.ToString().Trim()
                            Fix         = $Fix.ToString().Trim()
                        }

                        # Add each *.Vester.ps1 file found to the array
                        $TestFiles.Add($Vest)
                    } #ForEach GCI
                } Else {
                    throw "No *.Vester.ps1 files found at location '$TestPath'."
                } #If GCI

                $GCI = $null
            } ElseIf ($TestPath -like '*.Vester.ps1') {
                # Add the single file to the array if it matches *.Vester.ps1
                $TestFiles.Add($TestPath)
            } Else {
                # Because Vester tests have a very specific format,
                # and for future discoverability of that test if parent folder is specified,
                # prefer that tests are consciously named *.Vester.ps1
                throw "'$TestPath' does not match the *.Vester.ps1 naming convention for test files."
            } #If Test-Path
        } #ForEach -Test param entry
    } #process

    END {
        If ($TestFiles.Count -gt 0) {
            # Reduce default property set for readability
            $TypeData = @{
                TypeName = 'Vester.Test'
                DefaultDisplayPropertySet = 'Name','Scope','Description'
            }
            # Include -Force to avoid errors after the first run
            Update-TypeData @TypeData -Force

            $TestFiles
        } Else {
            Write-Verbose "No matching Vester tests found"
        }
    } #end
} #function
