#Requires -Modules Pester, VMware.VimAutomation.Core

# Gather all files
$PublicFunctions  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the functions
ForEach ($File in @($PublicFunctions + $PrivateFunctions)) {
    Try {
        . $File.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($File.FullName): $_"
    }
}

# Export the public functions for module use
Export-ModuleMember -Function $PublicFunctions.Basename
