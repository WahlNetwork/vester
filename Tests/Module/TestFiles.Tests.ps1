# Check each .Vester.ps1 test against general assumptions

Describe 'Unit Tests' -Tag 'unit' {
    $TestFiles = Get-ChildItem "$PSScriptRoot\..\..\Vester\Tests" -File -Recurse
    $cfg = @{}
        
    ForEach ($Test in $TestFiles) {
        # Use RegEx to help capture the line that defines the test's $cfg.abc.xyz value
        $CfgLine = ($Test | Select-String '\$cfg') -replace '.*\:[0-9]+\:',''
        $CfgLine.Count | Should Be 1

        # Use RegEx and matching to look for a type declaration
        If ($CfgLine -match '\[([a-z]+)\].*\$cfg\.([a-z]+)\.([a-z]+)$') {
            # $Desired is strongly typed ([int] | [bool] | [string])
            $Type = $Matches[1]
        } ElseIf ($CfgLine -match '\$(cfg)\.([a-z]+)\.([a-z]+)$') {
            # $Desired is not strongly typed, which we do when allowing arrays
            $Type = 'object'
        } Else {
            throw "Unable to match `$Desired line of test file $($Test.BaseName)"
        }

        # For the $Type discovered, set a dummy value of that type
        $CfgValue = switch ($Type) {
            'bool'   {$true}
            'int'    {1}
            'string' {'test'}
            'object' {@('1','2')}
        }

        # Still using the -match results, set this test's $cfg.abc.xyz
        $cfg.($Matches[2]) = @{$Matches[3] = $CfgValue}

        # Dot sourcing loads the four expected variables
        . $Test.FullName

        It "$(Split-Path $Test.FullName -Leaf) loads expected variables" {
            $Title   | Should Not BeNullOrEmpty
            $Desired | Should Not BeNullOrEmpty
            $Actual  | Should Not BeNullOrEmpty
            $Fix     | Should Not BeNullOrEmpty
        }

        It "$(Split-Path $Test.FullName -Leaf) variables have proper types" {
            $Title   | Should BeOfType String
            $Desired | Should BeOfType $Type
            $Actual  | Should BeOfType ScriptBlock
            $Fix     | Should BeOfType ScriptBlock
        }

        It "$(Split-Path $Test.FullName -Leaf) is properly scoped" {
            $Actual | Should BeLike '*$Object*'
            $Fix | Should BeLike '*$Object*'
            $Fix | Should BeLike '*$Desired*'
        }

        # Completely remove the loaded variables for the next test
        @('Title','Desired','Actual','Fix') | ForEach-Object {
            Remove-Variable -Name $_
        }
    } #ForEach $Test
} #Describe
