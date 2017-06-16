[cmdletbinding()]
Param (
    [string]$ApiKey,
    [string[]]$PowerShellModules = @("Pester","Psake","BuildHelpers","Plaster"),
    [string[]]$PackageProviders   = @('NuGet','PowerShellGet'),
    [string[]]$TaskList
)

# Install package providers for PowerShell Modules
ForEach ($Provider in $PackageProviders) {
    If (!(Get-PackageProvider $Provider -ErrorAction SilentlyContinue)) {
        Install-PackageProvider $Provider -Force -ForceBootstrap -Scope CurrentUser
    }
}

# Install the PowerShell Modules
ForEach ($Module in $PowerShellModules) {
    If (!(Get-Module -ListAvailable $Module -ErrorAction SilentlyContinue)) {
        Install-Module $Module -Scope CurrentUser -Force -Repository PSGallery
    }
    Import-Module $Module
}

Push-Location $PSScriptRoot
Write-Output "Retrieving Build Variables"
Get-ChildItem -Path env:\bh* | Remove-Item
Set-BuildEnvironment

If ($TaskList.Count -gt 0) {
    Write-Output "Executing Tasks: $TaskList`r`n"
    Invoke-Psake -buildFile .\psake.ps1 -properties $PSBoundParameters -noLogo -taskList $TaskList
} Else {
    Write-Output "Executing Unit Tests Only`r`n"
    Invoke-Psake -buildFile .\psake.ps1 -properties $PSBoundParameters -nologo
}
