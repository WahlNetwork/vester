# Modified Get-ChildItem for Vester purposes
# Handles the different logic paths allowed by Get-VesterTest

function Get-VesterChildItem {
    [CmdletBinding()]
    param (
        $Path,
        $Scope,
        $Name
    )

    If ($Scope -and $Name) {
        Get-ChildItem -Path $Path -Filter "$Name.Vester.ps1" -File -Recurse |
            Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                          @{n='Scope';e={($_.Directory -split '\\')[-1]}},
                          FullName |
            Where-Object Scope -in $Scope
    } ElseIf ($Scope) {
        Get-ChildItem -Path $Path -Filter '*.Vester.ps1' -File -Recurse |
            Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                          @{n='Scope';e={($_.Directory -split '\\')[-1]}},
                          FullName |
            Where-Object Scope -in $Scope
    } ElseIf ($Name) {
        Get-ChildItem -Path $Path -Filter "$Name.Vester.ps1" -File -Recurse |
            Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                          @{n='Scope';e={($_.Directory -split '\\')[-1]}},
                          FullName
    } Else {
        Get-ChildItem -Path $Path -Filter '*.Vester.ps1' -File -Recurse |
            Select-Object @{n='Name';e={($_.BaseName -split '\.')[0]}},
                          @{n='Scope';e={($_.Directory -split '\\')[-1]}},
                          FullName
    }
}
