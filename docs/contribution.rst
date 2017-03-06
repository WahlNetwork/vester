Contribution
========================

Everyone is welcome to contribute to this project. Here are the steps involved:

1. Create a fork of the project into your own repository.
2. From your fork, create a new feature branch (other than master) that expresses your feature or enhancement.
3. Make all your necessary changes in your feature branch.
4. Create a pull request with a description on what was added or removed and details explaining the changes in lines of code.

If approved, project owners will merge it.

Creating a New Test
------------------------

Vester tests are organized into subfolders below Vester\\Tests, with one folder per type of object tested (Cluster, VM, etc).

1. Identify a configuration value in your vSphere environment that isn't being inspected by Vester
2. Try and find a similar test for the same object type, for example: `Cluster/DRS-Level.Vester.ps1`_
3. Copy the existing test to a new file in the appropriate folder, ``<object type>\\<your new testname>.Vester.ps1``
4. Keeping the existing structure, edit each variable (``$Title $Description $Desired $Type $Actual`` and ``$Fix``) to perform your test.
5. Verify everything works as expected.  The commands to test are:
  * ``New-VestorConfig``
  * ``Invoke-Vester``
  * ``Invoke-Vester -Remediate -WhatIf``
  * ``Invoke-Vester -Remediate``

Note: For simplicity, you can limit execution to only your test with ``Invoke-Vester -Test c:\\path\\to\\mytest.Vester.ps1``

If everything works as expected, create your pull request and enjoy a sense of accomplishment! :D

.. _`Cluster/DRS-Level.Vester.ps1`: https://github.com/WahlNetwork/Vester/blob/master/Vester/Tests/Cluster/DRS-Level.Vester.ps1

Test Writing Tips:

* When editing ``$Desired = $cfg.<object type>.<your setting name>``, don't add more levels to the hierarchy, it doesn't appear to be supported at the moment.
* ``New-VesterConfig`` dynamically reads from the test scripts folder to generate a .json config file template. There is no need to define your new desired configuration setting outside your ``<test>.Vester.ps1`` file.