#requires -Version 2

# Static variables. Using MyDocuments var for those with redirected folders
$Basepath = [Environment]::GetFolderPath('MyDocuments') + '\WindowsPowerShell\Modules'
$InstallPath = $Basepath+'\Vester'

# Installer options
$title = 'Vester Module Installer'
$message = "Installation Path: $InstallPath`r`nAre you sure you wish to install or update your Vester module?"
$yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes', 'Yes'
$no = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList '&No', 'No'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

# Start installer
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result)
{
    0 
    {
        # Upgrade vs fresh install
        If (Test-Path -Path $InstallPath)
        {
            # Upgrade
			Write-Host -Object 'Found previous installation of Vester module. Updating ...'
            
			# Option to preserve user's .json config files
			$existingConfigs = gci -Path ($InstallPath + "\Configs\") -Filter "*.json"
			if( $existingConfigs ) {
				Write-Host "Found configuration file(s) in your install directory:`n"
				Write-Host $existingConfigs -ForegroundColor Green
				Write-Host "`nDo you want to keep your existing configuration(s)? Y/N [Y]"  -ForegroundColor Yellow -NoNewline
				if ( (Read-Host ' ') -like 'n*' ) {
					$existingConfigs = ""
				}
			}
			
			if( $existingConfigs ) {
				#Delete everything except Configs folder
				$null = gci -Path $InstallPath -Exclude "Configs" | Remove-Item -Recurse -Force
			}
			else {
				#Delete Everything
				$null = Remove-Item -Path $InstallPath -Recurse -Force
				$null = New-Item -ItemType Directory -Path $InstallPath
			}
        }
        Else 
        {
            # Install
            Write-Host -Object 'No previous installation of Vester module found. Installing ...'
            $null = New-Item -ItemType Directory -Path $InstallPath
        }

        # Copy over the module folder
        $null = Copy-Item $PSScriptRoot\Vester\* $InstallPath -Force -Recurse
        
        # Check the PSModulePath
        $pathtest = $env:PSModulePath.Split(';')
        if (!($pathtest -contains $Basepath))
        {
            #Save the current value in the $p variable.
            $p = [Environment]::GetEnvironmentVariable('PSModulePath','User')
            #Add the new path to the $p variable. Begin with a semi-colon separator.
            $p += ";$Basepath"
            #Add the paths in $p to the PSModulePath value.
            [Environment]::SetEnvironmentVariable('PSModulePath',$p,'User')
        }
        
        # Import the module
        try 
        {
            Import-Module -Name Vester -ErrorAction Stop
        }
        catch 
        {
            throw 'Error loading the Vester module'
        }
        Write-Host -Object "Vester module successfully installed and loaded.`r`nUse Get-Command -Module Vester to view all of the available cmdlets"
    }


    1 
    {
        Write-Host -Object 'Installation aborted'
    }
}