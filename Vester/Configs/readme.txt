Hi! By default, Config.json files will be generated in this folder by New-VesterConfig.

To get started, you can run either:

	Import-Module Vester
	New-VesterConfig
	
And follow the prompts, or:

	Import-Module Vester
	New-VesterConfig -Quiet
	
And quickly generate the file based off of the values of the first cluster/host/VM/etc. discovered.
