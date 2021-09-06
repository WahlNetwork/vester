# Used by New-VesterConfig to help populate values into a hashtable

function Set-VesterConfigValue {
    [CmdletBinding()]
    param (
        [ValidatePattern('^\$cfg\..*?\.')]
        $Line,
        
        $Value
    )

    $Split = $Line -split '\.'
    $1 = $Split[1]
    $2 = $Split[2]

    # Using parent scope variables $config, $Vest

    If ($config.$1.Keys -contains $2) {
        Write-Verbose "config.$1.$2 already exists; skipping $(Split-Path $Vest -Leaf)"
    } Else {
        # If config.host was already created in a previous ForEach loop,
        If ($config.$1) {
            # Use the hashtable's Add method to append another value
            $config.$1.Add($2, $Value)
            Write-Verbose "config.$1.$2 added"
        } Else {
            # Otherwise, create the first value in the new scope
            $config.$1 = @{$2 = $Value}
            Write-Verbose "config.$1.$2 added"
        }
    }
}
