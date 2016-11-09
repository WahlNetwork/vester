[CmdletBinding(SupportsShouldProcess = $true,
                ConfirmImpact = 'Medium')]
Param(
    $Remediate,
    $Scope,
    $InventoryList,
    $Title,
    $Desired,
    $Actual,
    $Fix
)

Describe -Name "$Scope Configuration: $(Split-Path $Test -Leaf)" -Fixture {
    ForEach ($Object in $InventoryList) {
        It -Name "$Scope $($Object.name) - $Title" -Test {
            Try {
                Compare-Object -ReferenceObject $Desired -DifferenceObject (& $Actual) | Should BeNullOrEmpty
            } Catch {
                If ($Remediate) {
                    Write-Warning -Message $_
                    If ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - $Scope '$Object'", "Set '$Title' value to '$Desired'")) {
                        Write-Warning -Message "Remediating $Object"
                        & $Fix
                    }
                } Else {
                    throw $_
                }
            } #Try/Catch
        } #It
    } #ForEach
} #Describe
