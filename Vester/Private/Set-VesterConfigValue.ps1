# Used by New-VesterConfig to help populate values into a hashtable

function Set-VesterConfigValue {
    [CmdletBinding()]
    param ($Value)

    # Using parent scope variables $config, $Matches, $Vest

    If ($config.($Matches[1]).Keys -contains $Matches[2]) {
        Write-Verbose "config.$($Matches[1]).$($Matches[2]) already exists; skipping $(Split-Path $Vest -Leaf)"
    } Else {
        # If config.host was already created in a previous ForEach loop,
        If ($config.($Matches[1])) {
            # Use the hashtable's Add method to append another value
            $config.($Matches[1]).Add($Matches[2], $Value)
            Write-Verbose "config.$($Matches[1]).$($Matches[2]) added"
        } Else {
            # Otherwise, create the first value in the new scope
            $config.($Matches[1]) = @{$Matches[2] = $Value}
            Write-Verbose "config.$($Matches[1]).$($Matches[2]) added"
        }
    }
}
