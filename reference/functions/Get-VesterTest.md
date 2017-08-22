---
external help file: Vester-help.xml
online version: https://wahlnetwork.github.io/Vester
schema: 2.0.0
---

# Get-VesterTest

## SYNOPSIS
Gather Vester test filepaths and details of each test.

## SYNTAX

```
Get-VesterTest [[-Path] <Object[]>] [[-Scope] <String[]>] [[-Name] <String[]>] [-Simple]
```

## DESCRIPTION
Get-VesterTest looks for .Vester.ps1 files, excludes some if the -Scope
or -Name parameters were specified, and then inspects each test file.
File path and detailed properties about each test are returned.

By default, all tests included with the module are inspected, and only
three properties are displayed: Name, Scope, and Description.

"Get-Help Get-VesterTest -Examples" for more details.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-VesterTest -Verbose
```

Displays the Name, Scope, and Description of all Vester test files
packaged with the module.
Verbose messages are available, if extra info is desired.

### -------------------------- EXAMPLE 2 --------------------------
```
Get-VesterTest | Select-Object -First 1 | Format-List *
```

Returns the first Vester test found from the module.
"Format-List *" displays all properties, instead of the default three.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-VesterTest -Scope Cluster,vCenter
```

Returns all Vester tests that apply to the "Cluster" and "vCenter" scopes.

### -------------------------- EXAMPLE 4 --------------------------
```
Get-VesterTest -Name 'CPU-Limits','ntp*'
```

Returns tests named "CPU-Limits" and tests starting with "NTP".
-Name is case insensitive.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-VesterTest -Path C:\Vester\CustomTest.Vester.ps1
```

-Path can be used to retrieve tests outside of the Vester module install.
Here, it collects info from CustomTest to return.

### -------------------------- EXAMPLE 6 --------------------------
```
Get-VesterTest -Path C:\Vester\
```

-Path can also be pointed at a directory containing custom tests.
Get-VesterTest will search here for all .Vester.ps1 files, recursively.

(Note that the immediate parent folder of all test files should have a
name matching the test's intended scope, like "VM".)

### -------------------------- EXAMPLE 7 --------------------------
```
Get-VesterTest -Scope VM -Simple
```

Returns only the file path of each test, instead of rich object details.
Invoke-Vester currently expects paths only, so this saves a little time
when supplying a filtered test suite to Invoke-Vester.

## PARAMETERS

### -Path
The file/folder path(s) to retrieve test info from.
If a directory, child .Vester.ps1 files are gathered recursively.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: "$(Split-Path -Parent $PSScriptRoot)\Tests\"
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Scope
Return only test files belonging to the specified Vester scope(s).
Vester determines test file scope by the name of its parent directory.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: @('Cluster','DSCluster','Host','Network','vCenter','VM')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Filter results by test name (e.g.
"DRS-Enabled" or "*DRS*").
-Name parameter is not case sensitive.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Simple
Simply return the full path of the file, instead of a rich object
Faster, as it does not inspect the contents of each Vester test file

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

## INPUTS

### [System.Object]
Accepts piped input(s) for parameter -Path.

## OUTPUTS

### [PSCustomObject] / [Vester.Test]
PSCustomObjects (with custom typename "Vester.Test") are returned.

[System.String]
If -Simple is active, only strings with each file's full path are returned.

## NOTES
"Get-Help about_Vester" for more information.

## RELATED LINKS

[https://wahlnetwork.github.io/Vester](https://wahlnetwork.github.io/Vester)

[https://github.com/WahlNetwork/Vester](https://github.com/WahlNetwork/Vester)

