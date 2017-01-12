Getting Started
========================

Invoke-Vester will run each test it finds and report on discrepancies. It compares actual values against the values you supply in a config file, and can fix them immediately if you include the -Remediate parameter. If you are not already connected to the vCenter server defined in the config file, Invoke-Vester will prompt for credentials to connect to it.

Invoke-Vester then calls Pester to run each test file. The test files leverage PowerCLI to gather values for comparison/remediation.

SYNTAX:
    Invoke-Vester [[-Config] <Object[]>] [[-Test] <Object[]>] [-Remediate] [[-XMLOutputFile] <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]

Example 1 - Validation using Defaults
------------------------

``PS C:\>Invoke-Vester -Verbose``

Using the default config file at \Vester\Configs\Config.json, Vester will run all included tests inside of \Vester\Tests\. Verbose output will be displayed on the screen. It outputs a report to the host of all passed and failed tests.

Example 2 - Validation using Custom Config and Test Path
------------------------

``PS C:\>Invoke-Vester -Config C:\Tests\Config.json -Test C:\Tests\``

Vester runs all *.Vester.ps1 files found underneath the C:\Tests\ directory, and compares values to the config file in the same location. It outputs a report to the host of all passed and failed tests.

Example 3 - Validation with Piped Test Values
------------------------

``PS C:\>$DNS = Get-ChildItem -Path Z:\ -Filter *dns*.Vester.ps1 -File -Recurse``
``PS C:\>(Get-ChildItem -Path Z:\ -Filter *.json).FullName | Invoke-Vester -Test $DNS``

Get all Vester tests below Z:\ with 'dns' in the name; store in variable $DNS. Then, pipe all *.json files at the root of Z: into the -Config parameter. Each config file piped in will run through all $DNS tests found.

Example 4 - Remediation with Custom Test Path and WhatIf
------------------------

``PS C:\>Invoke-Vester -Test .\Tests\VM -Remediate -WhatIf``

Run *.Vester.ps1 tests in the .\Tests\VM path below the current location. For all tests that fail against the values in \Configs\Config.json, -Remediate attempts to immediately fix them to match your defined config. -WhatIf prevents remediation, and instead reports what would have changed.

Example 5 - Remediation with Custom Config
------------------------

``PS C:\>Invoke-Vester -Config .\Config-Dev.json -Remediate``

Run all \Vester\Tests\ files, and compare values to those defined within the Config-Dev.json file at the current location. For all failed tests, -Remediate attempts to immediately correct your infrastructure to match the previously defined values in your config file.

Example 6 - Validation with XML Output
------------------------

``PS C:\>Invoke-Vester -XMLOutputFile .\vester.xml``

Runs Vester with the default config and test files. Uses Pester to send test results in NUnitXML format to vester.xml at your current folder location. Option is primarily used for CI/CD integration solutions.