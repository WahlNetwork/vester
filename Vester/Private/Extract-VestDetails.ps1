# Collect and report on Vester test details within Get-VesterTest

function Extract-VestDetails {
    [CmdletBinding()]
    param (
        $Object
    )

    Write-Verbose "[Extract-VestDetails] $($Object.Name)"

    # Create $Title/$Description/$Type/$Actual/$Fix from the test file
    . $Object.FullName
    
    #account for $Desired possibly being a script block. If it is don't do anything special (treat like $Actual)
    # if not get the value as before
    if ( -Not (Select-String -Path $Object.FullName -Pattern '\$Desired \=').Line.ToLower().Contains('scriptblock') ){
        # That doesn't work to find $Desired's value, so do it here
        $Desired = ((Select-String -Path $Object.FullName -Pattern '\$Desired \=').Line -split ' ')[-1]
   }
 
   # Output all properties for capturing in a $Vest variable
    [PSCustomObject]@{
        # Add a custom type name for this object
        # Used with DefaultDisplayPropertySet
        PSTypeName  = 'Vester.Test'
        Name        = $Object.Name
        Scope       = $Object.Scope
        FullName    = $Object.FullName
        Title       = $Title
        Description = $Description
        Recommendation = $Recommendation
        Desired     = $Desired
        Type        = $Type
        Actual      = $Actual.ToString().Trim()
        Fix         = $Fix.ToString().Trim()
    }
}
