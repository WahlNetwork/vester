Lab Config
======================

This is a community project that aims to provide an extremely light-weight approach to vSphere configuration management using Pester and PowerCLI. Each component monitored is both tested and remediated against drift. The end-state configuration is abstracted into a simple config file. The entire project is written in PowerShell.

# Requirements

You'll just need a few free pieces of software.

1. PowerShell version 4+
2. [PowerCLI version 5.8+](http://www.vmware.com/go/powercli)
5. [Pester](https://github.com/pester/Pester)
4. (optional) [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)

# Installation

Download the files contained within this project anywhere you want. You can even make different copies for different environments.

# Usage Instructions

1. Edit the `Config.ps1` file with your specific environmental variables for DRS, NTP, SSH, etc.
1. Open a PowerShell console.
2. Navigate to the project folder that you downloaded.
3. Run `Invoke-Pester` to launch the tests.

# Future

The community module is not officially supported and should be **used at your own risk**.

I'd like to see more tests added for things people find important. This will be done as time permits. :)

# Contribution

Everyone is welcome to contribute to this project. Here are the steps involved:

1. Create a fork of the project into your own repository.
2. From your fork, create a new feature branch (other than master) that expresses your feature or enhancement.
3. Make all your necessary changes in your feature branch.
4. Create a pull request with a description on what was added or removed and details explaining the changes in lines of code.

If approved, project owners will merge it.

# Licensing

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
