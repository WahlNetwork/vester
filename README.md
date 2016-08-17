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

### `Path` (string)

The relative path to where you have downloaded the Vester tests. Some folks like to use different versions of tests, or subdivide tests into smaller groups. The `path` input is required by Pester when sending parameters as shown in the examples below.

### `Remediate` (bool)

Set to `$true` to remediate any differences found. Set to `$false` to report on differences without remediation.

### `Config` (string)

The relative path to where you have located a Vester config file. You can use multiple config files to represent your different environments, such as Prod and Dev, while at the same time using the same testing files.

# Usage Instructions

The end-state configuration for each vSphere component is stored inside of the `Config.ps1` file. Make sure to read through the configuration items and set them with your specific environmental variables for DRS, NTP, SSH, etc.

If you have multiple environments that have unique settings, create a copy of the `Config.ps1` file for each environment and call it whatever you wish (such as `Config-Prod.ps1` for Production and `Config-Dev.ps1` for your Dev).

Once that's complete, you can start running Pester tests by opening your PowerShell console, using `Connect-VIServer` to authenticate to your vCenter Server, and finally using the parameters and examples below.

### Example 1 - Validation
`Invoke-Pester -Script @{Path = '.\Vester\Tests'; Parameters = @{ Remediate = $false ; Config = '.\Vester\Tests\Config.ps1' }}`

* Runs all tests found in the path `.\Vester\Tests`
* Remediation is `$false` (disabled) - drift will be shown but not corrected
* Configuration settings found in `.\Vester\Tests\Config.ps1` will be used.

### Example 2 - Remediation
`Invoke-Pester -Script @{Path = '.\Vester\Tests'; Parameters = @{ Remediate = $true ; Config = '.\Vester\Tests\Config-Prod.ps1' }}`

* Runs all tests found in the path `.\Vester\Tests`
* Remediation is `$true` (enabled) - drift will be shown and also corrected
* Configuration settings found in `.\Vester\Tests\Config-Prod.ps1` will be used.

### Example 3 - Single Test Validation
`Invoke-Pester -Script @{Path = '.\Vester\Tests'; Parameters = @{ Remediate = $false ; Config = '.\Vester\Tests\Config.ps1' }} -TestName '*DNS*'`

* Runs any test with the string `DNS` found in the name, using the path `.\Vester\Tests`
* Remediation is `$true` (enabled) - drift will be shown and also corrected
* Configuration settings found in `.\Vester\Tests\Config.ps1` will be used.

### Example 4 - Single Test Validation with NUnit Output (for Jenkins, AppVeyor, etc.)
`Invoke-Pester -Script @{Path = '.\Vester\Tests'; Parameters = @{ Remediate = $false ; Config = '.\Vester\Tests\Config.ps1' }} -TestName '*DNS*' -OutputFormat NUnitXml -OutputFile '.\Vester\Results'`

* Runs any test with the string `DNS` found in the name, using the path `.\Vester\Tests`
* Remediation is `$true` (enabled) - drift will be shown and also corrected
* Configuration settings found in `.\Vester\Tests\Config.ps1` will be used.
* The results of the tests will be stored in NUnit XML format in the path `.\Vester\Results\Sample.xml`

# Future

The community module is not officially supported and should be **used at your own risk**.

I'd like to see more tests added for things people find important. This will be done as time permits. :)

# Contribution

Everyone is welcome to contribute to this project. The goal is to add fine-grained tests that look at specific values within a vSphere environment, compare them to defined configuration value, and optionally remediate discrepancies if the user so decides. However, there is nothing wrong with submitting a pull request (PR) with a non-remediating test. This is a great starting point for those newer to coding with PowerShell!

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
