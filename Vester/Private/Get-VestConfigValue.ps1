function Get-VestConfigValue {
    <#
    .SYNOPSIS
    Extract the $cfg.blah.blah value each Vester test uses.

    .DESCRIPTION
    Get-VestConfigValue uses the abstract syntax tree (AST) to parse the test
    file, determine the $cfg value assigned to the $Desired variable within,
    and output that $cfg value as a string for New-VesterConfig to consume.

    .EXAMPLE
    C:\DNS-Address.Vester.ps1 | Get-VestConfigValue
    Returns the $cfg.blah.blah value assigned to the $Desired variable.

    .NOTES
    Consulted @ThmsRynr's AstHelper & @MathieuBuisson's PSCodeHealth modules. Thanks!
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $Vest
    )

    Write-Verbose "[Get-VestConfigValue] started for $(Split-Path $Vest -Leaf)"
    
    $parse = [System.Management.Automation.Language.Parser]::ParseFile($Vest, [ref]$null, [ref]$null)
    
    $ast = $parse.FindAll({$args[0] -is 'System.Management.Automation.Language.AssignmentStatementAst'}, $true)

    $Output = $ast | Where-Object {
        $_.Left.Extent.Text  -eq '$Desired' -and
        $_.Right.Extent.Text -like '$cfg.*'
    }

    Write-Debug "$($Output.Count) of $($ast.Count) objects will return. Inspect `$ast and `$Output for details"

    Write-Output $Output.Right.Extent.Text
}
