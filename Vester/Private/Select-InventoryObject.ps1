# Called by New-VesterConfig
# Helps the user interactively select which inventory object (Cluster, Host, VM, etc.)
# to pull initial config file values from

function Select-InventoryObject {
    [CmdletBinding()]
    param (
        $ObjectList,
        [string]$Scope
    )

    Write-Host "`n     Listing objects in scope $Scope"

    # List objects to choose from
    If ($ObjectList.Count -eq 1) {
        # That was easy
        Write-Host "One object found; selecting $Scope '$ObjectList'"
        Write-Output $ObjectList
    } ElseIf ($ObjectList.Count -gt 1) {
        for ($i = 1; $i -le $ObjectList.Count; $i++) {
            Write-Host "$i. " -ForegroundColor Green -NoNewline
            Write-Host "$($ObjectList.Name[$i-1])"
        }

        # Choose an object (repeat until valid input)
        while (1..$ObjectList.Count -notcontains $Selection) {
            $Selection = [int](Read-HostColor "`n-- Select the number of the $Scope object to pull values from")
        }

        Write-Output $ObjectList[$Selection - 1]
    }
}
