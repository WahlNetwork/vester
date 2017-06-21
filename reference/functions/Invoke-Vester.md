---
external help file: Vester-help.xml
online version: http://vester.readthedocs.io/en/latest/
schema: 2.0.0
---

# Invoke-Vester

## SYNOPSIS
Test and fix configuration drift in your VMware vSphere environment.

## SYNTAX

```
Invoke-Vester [[-Config] <Object[]>] [[-Test] <Object[]>] [-Remediate] [[-XMLOutputFile] <Object>] [-PassThru]
 [-WhatIf] [-Confirm]
```

## DESCRIPTION
Invoke-Vester will run each test it finds and report on discrepancies.
It compares actual values against the values you supply in a config file,
and can fix them immediately if you include the -Remediate parameter.

If you are not already connected to the vCenter server defined in the
config file, Invoke-Vester will prompt for credentials to connect to it.

Invoke-Vester then calls Pester to run each test file.
The test files
leverage PowerCLI to gather values for comparison/remediation.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-Vester -Verbose
```

Using the default config file at \Vester\Configs\Config.json,
Vester will run all included tests inside of \Vester\Tests\.
Verbose output will be displayed on the screen.
It outputs a report to the host of all passed and failed tests.

### -------------------------- EXAMPLE 2 --------------------------
```
Invoke-Vester -Config C:\Tests\Config.json -Test C:\Tests\
```

Vester runs all *.Vester.ps1 files found underneath the C:\Tests\ directory,
and compares values to the config file in the same location.
It outputs a report to the host of all passed and failed tests.

### -------------------------- EXAMPLE 3 --------------------------
```
$DNS = Get-ChildItem -Path Z:\ -Filter *dns*.Vester.ps1 -File -Recurse
```

PS C:\\\>(Get-ChildItem -Path Z:\ -Filter *.json).FullName | Invoke-Vester -Test $DNS

Get all Vester tests below Z:\ with 'dns' in the name; store in variable $DNS.
Then, pipe all *.json files at the root of Z: into the -Config parameter.
Each config file piped in will run through all $DNS tests found.

### -------------------------- EXAMPLE 4 --------------------------
```
Invoke-Vester -Test .\Tests\VM -Remediate -WhatIf
```

Run *.Vester.ps1 tests in the .\Tests\VM path below the current location.
For all tests that fail against the values in \Configs\Config.json,
-Remediate attempts to immediately fix them to match your defined config.
-WhatIf prevents remediation, and instead reports what would have changed.

### -------------------------- EXAMPLE 5 --------------------------
```
Invoke-Vester -Config .\Config-Dev.json -Remediate
```

Run all \Vester\Tests\ files, and compare values to those defined within
the Config-Dev.json file at the current location.
For all failed tests, -Remediate attempts to immediately correct your
infrastructure to match the previously defined values in your config file.

### -------------------------- EXAMPLE 6 --------------------------
```
Invoke-Vester -XMLOutputFile .\vester.xml
```

Runs Vester with the default config and test files.
Uses Pester to send test results in NUnitXML format to vester.xml
at your current folder location.
Option is primarily used for CI/CD integration solutions.

## PARAMETERS

### -Config
Optionally define a different config file to use
Defaults to \Vester\Configs\Config.json

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: FullName

Required: False
Position: 1
Default value: "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json"
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Test
Optionally define the file/folder of test file(s) to call
Defaults to \Vester\Tests\, grabbing all tests recursively
All test files must be named *.Vester.ps1

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: Path, Script

Required: False
Position: 2
Default value: "$(Split-Path -Parent $PSScriptRoot)\Tests\"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remediate
Optionally fix all config drift that is discovered
Defaults to false (disabled)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -XMLOutputFile
Optionally save Pester output in NUnitXML format to a specified path
Specifying a path automatically triggers Pester in NUnitXML mode

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Optionally returns the Pester result as an object containing the information about the whole test run, and each test
Defaults to false (disabled)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### [System.Object]
Accepts piped input (optional multiple objects) for parameter -Config

## OUTPUTS

## NOTES
This command relies on the Pester and PowerCLI modules for testing.

"Get-Help about_Vester" for more information.

## RELATED LINKS

[http://vester.readthedocs.io/en/latest/](http://vester.readthedocs.io/en/latest/)

[https://github.com/WahlNetwork/Vester](https://github.com/WahlNetwork/Vester)

