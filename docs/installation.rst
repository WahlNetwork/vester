Installation
========================

This repository contains a folder named `Vester`_. The folder needs to be installed into one of your PowerShell Module Paths using one of the installation methods outlined in the next section. Common PowerShell module paths include:

1. Current User: ``%USERPROFILE%\Documents\WindowsPowerShell\``
2. All Users: ``%WINDIR%\System32\WindowsPowerShell\v1.0\``

Option 1: Installer Script
------------------------

1. Download the `latest release`_ or any pre-release build to your workstation.
2. Open a Powershell console with the *Run as Administrator* option.
3. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
4. Run the ``Install-Vester.ps1`` script in the root of this repository and follow the prompt to install the module into your ``$Home\Documents\WindowsPowerShell\Modules\`` path.
5. At the completion of the installation, the installer will run ``Import-Module Vester`` on your behalf.

Option 2: Manual Installation
------------------------

1. Download the `latest release`_ or any pre-release build to your workstation.
2. Copy the contents of the *Vester* folder onto your workstation into the PowerShell Module Path ``$Home\Documents\WindowsPowerShell\Modules\`` or ``C:\Program Files\WindowsPowerShell\Modules``
3. Open a Powershell console with the *Run as Administrator* option.
4. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
5. To load the module, use ``Import-Module Vester``.

Option 3: PowerShell Gallery
------------------------

1. Ensure you have the `Windows Management Framework 5.0`_ or greater installed.
2. Open a Powershell console with the *Run as Administrator* option.
3. Run ``Set-ExecutionPolicy`` using the parameter *RemoteSigned* or *Bypass*.
4. Run ``Install-Module -Name Vester`` to download the module from the PowerShell Gallery. Note that the first time you install from the remote repository it may ask you to first trust the repository.

Once installation is complete, you can validate that the module exists by running ``Get-Module -ListAvailable Vester``.

.. _Vester: https://github.com/WahlNetwork/Vester/tree/master/Vester
.. _latest release: https://github.com/WahlNetwork/Vester
.. _Windows Management Framework 5.0: https://www.microsoft.com/en-us/download/details.aspx?id=50395

Verification
------------------------

PowerShell will create a folder for each new version of any module you install. It's a good idea to check and see what version(s) you have installed and running in the session. To begin, let's see what versions of the Vester Module are installed:

``Get-Module -ListAvailable Vester``

The ``-ListAvailable`` switch will pull up all installed versions from any path found in ``$env:PSModulePath``. Check to make sure the version you wanted is installed. You can safely remove old versions, if desired.

To see which version is currently loaded, use:

``Get-Module Vester``

If nothing is returned, you need to first load the module by using:

``Import-Module Vester``

If you wish to load a specific version, use:

``Import-Module Vester -RequiredVersion #.#.#.#``

Where "#.#.#.#" represents the version number.