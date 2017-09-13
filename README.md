# Vester

Vester is a community project that provides an extremely light-weight approach to configuration management of your VMware environment. Store desired values for vSphere components (like clusters and hosts) in a simple config file. If the values in your config file don't match the values in your environment, you can report on--and optionally fix--those discrepancies.

Vester is written entirely in PowerShell, using [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/) and [Pester](https://github.com/Pester/Pester). Config files are stored as json documents that can easily live in source control.

## Getting Started

Vester 1.2 in ten minutes at VMworld US 2017: [vBrownBag video](https://youtu.be/9TRZ30XhK10)

Download Vester from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Vester/).

```posh
Install-Module Vester
```

This [three-part blog series](http://www.brianbunke.com/blog/2017/03/07/introducing-vester/) from March 2017 walks you through getting started with v1.0. It still holds up; the main difference is the new `Get-VesterTest` function, making tests easier to fetch and explore.

## Documentation

You can find live docs online! https://wahlnetwork.github.io/Vester

Or in your PowerShell console:

```posh
Get-Command -Module Vester
Get-Help about_Vester
Get-Help Get-VesterTest -Full
```

**[Current changelog](https://github.com/WahlNetwork/Vester/blob/master/CHANGELOG.md)**

## Questions?

If you found a bug, would like to submit a feature request, or just have a question about Vester, feel free to search our [issues](https://github.com/WahlNetwork/Vester/issues) page, and create a new item if nothing fits the bill.

You're also welcome to come hang out in the #vester channel of the VMware {code} Slack workspace. [Sign up for VMware {code}](https://code.vmware.com/join), and you'll receive a Slack invite via email.
