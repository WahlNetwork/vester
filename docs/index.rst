Vester - Configuration Management for vSphere
========================

.. image:: https://ci.appveyor.com/api/projects/status/52cv3jshak2w7624?svg=true
   :target: https://ci.appveyor.com/project/chriswahl/powershell-module

.. image:: http://readthedocs.org/projects/powershell-module/badge/?version=latest
   :target: http://powershell-module.readthedocs.io/en/latest/?badge=latest

Vester is a community project that aims to provide an extremely light-weight approach to vSphere configuration management using Pester and PowerCLI. The end-state configuration for each vSphere component, such as clusters and hosts, are abstracted into a simple config file. The configuration is tested and optionally remediated when drift is identified. The entire project is written in PowerShell. The code is open source, and `available on GitHub`_.

.. _available on GitHub: https://github.com/WahlNetwork/Vester

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: User Documentation

   requirements
   installation
   getting_started
   support
   contribution
   licensing  
   faq

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: Command Documentation

   cmd_connect
   cmd_get
   cmd_new
   cmd_protect
   cmd_remove
   cmd_set
   cmd_start
   cmd_stop
   cmd_sync

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: Workflow Examples

   flow_audit
   flow_backup_validation
