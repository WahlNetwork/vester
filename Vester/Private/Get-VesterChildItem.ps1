# Modified Get-ChildItem for Vester purposes
# Handles the different logic paths allowed by Get-VesterTest

function Get-VesterChildItem {
    [CmdletBinding()]
    param (
        $Path,
        $Scope,
        $Name,
        # Prevent @PSBoundParameters invocation error, but don't do anything
        $Simple
    )

    # Determine path separater character for this platform
    $sep = '\\'
    If ($pwd.path.contains('/')) {
      $sep = '/'
    }

    # cross-platform support
    $Path = (Get-Item $Path).FullName

    Write-Verbose "[Get-VesterChildItem] $Path"

    If ($Scope -and $Name) {
        $Name | ForEach-Object {
            Get-ChildItem -Path $Path -Filter "$_.Vester.ps1" -File -Recurse |
                Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                                @{n='Scope';e={($_.Directory -split $sep)[-1]}},
                                FullName |
                Where-Object Scope -in $Scope
        }
    } ElseIf ($Scope) {
        Get-ChildItem -Path $Path -Filter '*.Vester.ps1' -File -Recurse |
            Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                            @{n='Scope';e={($_.Directory -split $sep)[-1]}},
                            FullName |
            Where-Object Scope -in $Scope
    } ElseIf ($Name) {
        $Name | ForEach-Object {
            Get-ChildItem -Path $Path -Filter "$_.Vester.ps1" -File -Recurse |
                Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                                @{n='Scope';e={($_.Directory -split $sep)[-1]}},
                                FullName
        }
    } Else {
        Get-ChildItem -Path $Path -Filter '*.Vester.ps1' -File -Recurse |
            Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                            @{n='Scope';e={($_.Directory -split $sep)[-1]}},
                            FullName
    }
}
