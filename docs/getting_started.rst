Getting Started
========================

This project ultimately uses Pester to provide the testing framework. Because of this, we leverage a combination of Pester variables and custom ones written for Vester. If you're wondering why the command structure looks a bit complex, reference `Pester Issue 271`_ and `Pester Issue 423`_.

.. _Pester Issue 271: https://github.com/pester/Pester/issues/271
.. _Pester Issue 271: https://github.com/pester/Pester/issues/423

Path Variable
------------------------

Type: String

* Used to tell ``Invoke-Pester`` the relative path to where you have downloaded the Vester tests.
* Some folks like to use different versions of tests, or subdivide tests into smaller groups.
* The ``path`` input is required by Pester when sending parameters as shown in the examples below.
 
Default:
    None hard-coded. Your current location when calling ``Invoke-Pester``, or the relative/absolute path you provide

Remediate Variable
------------------------

Type: Bool (boolean)

* Tells Vester in which mode to operate.
* Set to ``$false`` to report on differences without any remediation.
* Set to ``$true`` to report on differences while also trying to remediate them.

Default:
    ``$false``

Config Variable
------------------------

Type: String

* The relative path to where you have located a Vester config file.
* You can use multiple config files to represent your different environments, such as Prod and Dev, while at the same time using the same testing files.

Default:
    ``Vester\Configs\Config.ps1``

Usage Instructions
-------------------------

The end-state configuration for each vSphere component is stored inside of the ``Config.ps1`` file. Make sure to read through the configuration items and set them with your specific environmental variables for DRS, NTP, SSH, etc.

If you have multiple environments that have unique settings, create a copy of the ``Config.ps1`` file for each environment and call it whatever you wish (such as ``Config-Prod.ps1`` for Production and ``Config-Dev.ps1`` for your Dev).

Once that's complete, you can start running Pester tests by opening your PowerShell console, using ``Connect-VIServer`` to authenticate to your vCenter Server, and finally using the parameters and examples below.

.. image:: http://i.imgur.com/qXrGlar.png
   :target: https://www.youtube.com/watch?v=CyVfzZ4jA8Q

Example 1 - Validation using Defaults
---------------------------

``Invoke-Pester .\Vester``

* Runs all tests underneath directory ``.\Vester``
* Will validate that the default config file has proper values first, then run all tests
* Uses the default remediation value of ``$false`` (disabled) - drift will be shown but not corrected
* Uses the default configuration settings found in ``.\Vester\Configs\Config.ps1``

Example 2 - Validation using Different Config Values
---------------------------

``Invoke-Pester -Script @{Path = '.\Vester'; Parameters = @{ Config = '.\Vester\Configs\Config-Prod.ps1' }}``

* Runs all tests underneath directory ``.\Vester``. Path is mandatory if supplying a parameter
* Will validate config and then run all tests
* Configuration settings found in ``.\Vester\Configs\Config-Prod.ps1`` will be used
* By not supplying the Remediate parameter, it defaults to ``$false``

Example 3 - Remediation using Different Config Values
---------------------------

``Invoke-Pester -Script @{Path = '.\Vester\Tests'; Parameters = @{ Remediate = $true ; Config = '.\Vester\Configs\Config-Prod.ps1' }}``

* Runs all tests found in the path ``.\Vester\Tests``
* Remediation is ``$true`` (enabled) - drift will be shown and also corrected
* Configuration settings found in ``.\Vester\Configs\Config-Prod.ps1`` will be used

Example 4 - Single Test Validation and NUnit Output (for Jenkins, AppVeyor, etc.)
---------------------------

``Invoke-Pester .\Vester\Tests -TestName '*DNS*' -OutputFormat NUnitXml -OutputFile .\Vester\results.xml``

* Runs any test under the path ``.\Vester\Tests`` with the string "DNS" found in the name
* NUnitXml output will be created in the file ``.\Vester\results.xml``
* Because there are no hashtables ``@{}``, defaults for Config/Remediate would be used
* Can easily be combined with Examples 2-3 to use a different config file and/or remediate

Example 5 - Validation using Tags
---------------------------

``Invoke-Pester .\Vester\Tests -Tag host -ExcludeTag nfs``

* At the path ``.\Vester\Tests``, runs all tests with the "host" tag, except for those also tagged "nfs"
* Because there are no hashtables ``@{}``, defaults for Config/Remediate would be used
* Can easily be combined with Examples 2-3 to use a different config file and/or remediate