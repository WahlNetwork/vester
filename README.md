Vester
======================

Vester is a community project that aims to provide an extremely light-weight approach to vSphere configuration management using Pester and PowerCLI. The end-state configuration for each vSphere component, such as clusters and hosts, are abstracted into a simple config file. The configuration is tested and optionally remediated when drift is identified. The entire project is written in PowerShell.

![Example](/Media/lab-config-example.jpg?raw=true "Example")

# Requirements

You'll just need a few free pieces of software.

1. PowerShell version 4+
2. [PowerCLI version 5.8+](http://www.vmware.com/go/powercli)
5. [Pester](https://github.com/pester/Pester)
4. (optional) [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)

# Installation

Because this repository is simply a collection of Pester tests, there is no installation. Download the files contained within this project anywhere you want.

# Variables

This project ultimately uses Pester to provide the testing framework. Because of this, we leverage a combination of Pester variables and custom ones written for Vester.

### `Path` (string)

* Used to tell `Invoke-Pester` the relative path to where you have downloaded the Vester tests.
* Some folks like to use different versions of tests, or subdivide tests into smaller groups.
* The `path` input is required by Pester when sending parameters as shown in the examples below.
 
Default: None hard-coded. Your current location when calling Invoke-Pester, or the relative/absolute path you provide

### `Remediate` (bool)

* Tells Vester in which mode to operate.
* Set to `$false` to report on differences without any remediation.
* Set to `$true` to report on differences while also trying to remediate them.

Default: `$false`

### `Config` (string)

* The relative path to where you have located a Vester config file.
* You can use multiple config files to represent your different environments, such as Prod and Dev, while at the same time using the same testing files.

Default: `Vester\Configs\Config.ps1`

# Usage Instructions

The end-state configuration for each vSphere component is stored inside of the `Config.ps1` file. Make sure to read through the configuration items and set them with your specific environmental variables for DRS, NTP, SSH, etc.

If you have multiple environments that have unique settings, create a copy of the `Config.ps1` file for each environment and call it whatever you wish (such as `Config-Prod.ps1` for Production and `Config-Dev.ps1` for your Dev).

Once that's complete, you can start running Pester tests by opening your PowerShell console, using `Connect-VIServer` to authenticate to your vCenter Server, and finally using the parameters and examples below.

[![Watch the Tutorial on YouTube](http://i.imgur.com/qXrGlar.png)](https://www.youtube.com/watch?v=CyVfzZ4jA8Q "Watch the Tutorial on YouTube")

### Example 1 - Validation using Defaults
`Invoke-Pester .\Vester`

* Runs all tests underneath directory `.\Vester`
* Will validate that the default config file has proper values first, then run all tests
* Uses the default remediation value of `$false` (disabled) - drift will be shown but not corrected
* Uses the default configuration settings found in `.\Vester\Configs\Config.ps1`

### Example 2 - Validation using Different Config Values
`Invoke-Pester -Script @{Path = '.\Vester'; Parameters = @{ Config = '.\Vester\Configs\Config-Prod.ps1' }}`

* Runs all tests underneath directory `.\Vester`. Path is mandatory if supplying a parameter
* Will validate config and then run all tests
* Configuration settings found in `.\Vester\Configs\Config-Prod.ps1` will be used
* By not supplying the Remediate parameter, it defaults to $false

### Example 3 - Remediation using Different Config Values
`Invoke-Pester -Script @{Path = '.\Vester\Tests'; Parameters = @{ Remediate = $true ; Config = '.\Vester\Configs\Config-Prod.ps1' }}`

* Runs all tests found in the path `.\Vester\Tests`
* Remediation is `$true` (enabled) - drift will be shown and also corrected
* Configuration settings found in `.\Vester\Configs\Config-Prod.ps1` will be used

### Example 4 - Single Test Validation and NUnit Output (for Jenkins, AppVeyor, etc.)
`Invoke-Pester .\Vester\Tests -TestName '*DNS*' -OutputFormat NUnitXml -OutputFile .\Vester\results.xml`

* Runs any test under the path `.\Vester\Tests` with the string `DNS` found in the name
* NUnitXml output will be created in the file .\Vester\results.xml
* Because there are no hashtables `@{}`, defaults for Config/Remediate would be used
* Can easily be combined with Examples 2-3 to use a different config file and/or remediate

### Example 5 - Validation using Tags
`Invoke-Pester .\Vester\Tests -Tag host -ExcludeTag nfs`

* At the path `.\Vester\Tests`, runs all tests with the "host" tag, except for those also tagged "nfs"
* Because there are no hashtables `@{}`, defaults for Config/Remediate would be used
* Can easily be combined with Examples 2-3 to use a different config file and/or remediate
 
# Future

The community module is not officially supported and should be **used at your own risk**.

I'd like to see more tests added for things people find important. This will be done as time permits. :)

# Contribution

Everyone is welcome to contribute to this project. The goal is to add fine-grained tests that look at specific values within a vSphere environment, compare them to defined configuration value, and optionally remediate discrepancies if the user so decides. However, there is nothing wrong with submitting a pull request (PR) with a non-remediating test. This is a great starting point for those newer to coding with PowerShell!

### Contribution Requirements

Every test that is added to Vester needs three things:

1. An update to the example [`Config.ps1`](https://github.com/WahlNetwork/Vester/blob/master/Configs/Config.ps1) file with your required configuration value(s), comments, and accepted input type.
2. An update to the [`Config.Tests.ps1`](https://github.com/WahlNetwork/Vester/blob/master/Configs/Config.Tests.ps1) file to validate that the `Config.ps1` file contains valid entries.
3. A test file using a properly formatted `Verb-Noun` format (use `Get-Verb` for more details) placed into the Tests folder.

### Your First Contribution

If you're looking for your first bit of code to add, try this list:

1. Identify a configuration value in your vSphere environment that isn't being inspected by Vester.
2. Use the [Template](https://github.com/WahlNetwork/Vester/blob/master/Templates/Update-Template.ps1) to create a test that inspects this value and try it out locally.
3. At this point you can submit a pull request (PR) for a non-remediating test. If someone else wants the remediation code added, they will grab your code and write that portion.
4. Optionally, write the remediation portion yourself to make a fully remediating test.

### Contribution Process

1. Create a fork of the project into your own repository.
2. From your fork, create a new feature branch (other than master) that expresses your feature or enhancement.
3. Make all your necessary changes in your feature branch.
4. Create a pull request with a description on what was added or removed and details explaining the changes in lines of code.

If approved, project owners will merge it.

# Licensing

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
