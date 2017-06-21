---
external help file: Vester-help.xml
online version: http://vester.readthedocs.io/en/latest/
schema: 2.0.0
---

# New-VesterConfig

## SYNOPSIS
Generates a Vester config file from settings in your existing VMware environment.

## SYNTAX

```
New-VesterConfig [[-OutputFolder] <Object>] [-Quiet]
```

## DESCRIPTION
New-VesterConfig is designed to be a quick way to get started with Vester.

Vester needs one config file for each vCenter server it interacts with.
To
help speed up this one-time creation process, New-VesterConfig uses PowerCLI
to pull current values from your environment to store in the config file.

You'll be prompted with the list of Clusters/Hosts/VMs/etc.
discovered, and
asked to choose one of each type to use as a baseline; i.e.
"all my other
hosts should be configured like this one." Those values are displayed
interactively, and you can manually edit them as desired.

Optionally, advanced users can use the -Quiet parameter.
This suppresses
all host output and prompts.
Instead, values are pulled from the first
Cluster/Host/VM/etc.
found alphabetically.
Manual review afterward of the
config file is strongly encouraged if using the -Quiet parameter.

It outputs a single Config.json file at \Vester\Configs, which may require
admin rights.
Optionally, you can use the -OutputFolder parameter to
specify a different folder to store the Config.json file.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-VesterConfig
```

Ensures that you are connected to only one vCenter server.
Based on all Vester test files found in '\Vester\Tests', the command
discovers values from your environment and displays them, occasionally
prompting for a selection of which cluster/host/etc.
to use.
Outputs a new Vester config file to '\Vester\Configs\Config.json',
which may require admin rights.

### -------------------------- EXAMPLE 2 --------------------------
```
New-VesterConfig -Quiet -OutputFolder "$env:USERPROFILE\Desktop"
```

-Quiet suppresses all host output and prompts, instead pulling values
from the first cluster/host/etc.
found alphabetically.
Upon completion, Config.json will be created on your Desktop.

## PARAMETERS

### -OutputFolder
Select a folder to create a new Config.json file inside

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: "$(Split-Path -Parent $PSScriptRoot)\Configs"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
Suppress all prompts and Write-Host.
Create the config file
with the values of the first Cluster/Host/VM/etc.
found.

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

## OUTPUTS

## NOTES
This command relies on the Pester and PowerCLI modules for testing.

"Get-Help about_Vester" for more information.

## RELATED LINKS

[http://vester.readthedocs.io/en/latest/](http://vester.readthedocs.io/en/latest/)

[https://github.com/WahlNetwork/Vester](https://github.com/WahlNetwork/Vester)

