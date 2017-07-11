# Private function to collect *.Vester.ps1 files in the target directory
# Exports a list of each test's FullName (Get-Item / Get-ChildItem property)

function Get-VesterTest {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [object[]]$Test
    )

    BEGIN {
        # Construct empty array to throw file paths of tests into
        $TestFiles = New-Object 'System.Collections.Generic.List[String]'
    }

    PROCESS {
        # Need to ForEach if multiple -Test locations
        ForEach ($TestPath in $Test) {
            # Gracefully handle FileSystemInfo objects (Get-Item / Get-ChildItem)
            If ($TestPath.FullName) {
                $TestPath = $TestPath.FullName
            }

            If (Test-Path $TestPath -PathType Container) {
                # If Test-Path finds a folder, get all *.Vester.ps1 files beneath it
                Write-Verbose "Discovering *.Vester.ps1 files below directory '$TestPath'."
                $GCI = (Get-ChildItem $TestPath -Filter '*.Vester.ps1' -File -Recurse).FullName

                If ($GCI) {
                    # Add each *.Vester.ps1 file found to the array
                    $GCI | ForEach-Object {
                        $TestFiles.Add($_)
                    }
                } Else {
                    throw "No *.Vester.ps1 files found at location '$TestPath'."
                }

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
        $TestFiles
    }
} #function
