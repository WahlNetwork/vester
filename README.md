Lab Config
======================
A collection of simple scripts that run against a vSphere environment to enforce consistency and enables self-healing on a regular basis. The premise is that you'd want to fill out a vars file with your standards, and then let the script engine run hourly / nightly / weekly to control drift and absorb new assets that are brought online.

## Description
Pretty straight forward. The engine's job is to start up a job for each script. Each script parses the vars file to determine what variables and options you want enforced.
- Set standards for a lab environment (which is what I do) and use a pull or utility server to run the engine on a schedule.
- Pick apart the scripts to use with other orchestration engines, or just as ideas for your code.

## Installation
Copy or fork the repo into your environment. Make sure you have PowerShell 4+ installed, along with PowerCLI 5.8+. The scripts are not signed, so you'll need to adjust your PowerShell ExecutionPolicy based on where you're running the engine file.

## Usage Instructions
Update the vars.ps1 file with your domain specific information. Run the engine.ps1 file, which will call all of the scripts in the various folders. If you don't want to run all of the scripts, open up the engine.ps1 file and edit the $jobMap variable and remove references to the scripts you wish to remove.

Here's an example of what the $jobMap var looks like:
```
$jobMap = [Ordered]@{
  "DNS"    = "\VMware\set-dns.ps1";
  "NTP"    = "\VMware\set-ntp.ps1";
  "SSH"    = "\VMware\set-ssh.ps1"
}
```

## Future
This is mainly a lab helper for Wahl Network, but I figured the code examples might be interesting to folks, or others with home labs might want to take advantage of the scripts.
- Microsoft scripts
  - DNS for clients
  - Network RSS settings
  - WinRM control
- More 3rd party stuff
  - PernixData is on my radar

## Contribution
Create a fork of the project into your own reposity. Make all your necessary changes and create a pull request with a description on what was added or removed and details explaining the changes in lines of code. If approved, project owners will merge it.

Licensing
---------
Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Support
-------
Please file bugs and issues at the Github issues page. The code and documentation are released with no warranties or SLAs and are intended to be supported through a community driven process.
