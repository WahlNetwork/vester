# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    $ProjectRoot   = $env:BHProjectPath
    $ChocolateyPackages = @('nodejs','calibre')
    $NodeModules        = @('gitbook-cli','gitbook-summary')
    $Timestamp     = Get-date -uformat "%Y%m%d-%H%M%S"
    $ApiKey        = $env:APIKEY
    $CompilingFolder = "$env:BHProjectPath/compiled_docs"
    $OutputPdfPath   = "$ProjectRoot/$env:BHProjectName.pdf"
    $OutputSitePath  = "$ProjectRoot/public"
}

Task Default -Depends InstallPrerequisites

Task InstallChocolatey {
    # Install Chocolatey
    If (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        # Check to see if admin; if not, this will fail!
        If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
            Write-Error "Chocolatey is not installed; Administrator permissions are required to install chocolatey`r`nPlease elevate your permissions and try again."
        } Else {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
    }
}

Task InstallChocolateyPackages -depends InstallChocolatey {
    # Install needed chocolatey packages
    ForEach ($Package in $ChocolateyPackages) {
        If (!(choco list --local-only | Where-Object {$_ -Match "^${Package}\s"})) {
            If (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
                Write-Error "Administrator permissions are required to install chocolatey packages`r`nPlease elevate your permissions and try again."
            } Else {
                choco install $Package -y
            }
        }
    }
    # Update the Path Variables
    Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
    Update-SessionEnvironment
}

Task InstallNodePackages -depends InstallChocolateyPackages {
    If (Get-Command npm -ErrorAction SilentlyContinue) {
        $GloballyInstalledModules = (npm ls --global --json | convertfrom-json).Dependencies
        ForEach ($Module in $NodeModules) {
            If ([string]::IsNullOrEmpty($GloballyInstalledModules."$Module")) {
                npm install -g $module
            }
        }
    } Else {Write-Warning "NPM not found; node modules not installed!"}
}

Task InstallPrerequisites -depends InstallNodePackages

Task Clean {
    If (Test-Path $CompilingFolder) {
        Remove-Item $CompilingFolder -Recurse -Force
    }
    If (Test-Path $OutputSitePath) {
        Remove-Item $OutputSitePath -Recurse -Force
    }
    If (Test-Path $OutputPdfPath) {
        Remove-Item $OutputPdfPath
    }
}

Task Compile -depends Clean {
    Write-Host -ForegroundColor DarkMagenta "Scaffolding the compiling folder..."
    $null = mkdir $CompilingFolder

    Write-Host -ForegroundColor DarkMagenta "Copying metadocuments..."
    Copy-Item -Path $ProjectRoot/*.md -Destination $CompilingFolder -Force

    Write-Host -ForegroundColor DarkMagenta "Copying documents..."
    Copy-Item -Path $ProjectRoot/docs/* -Destination $CompilingFolder -Recurse -Force

    Write-Host -ForegroundColor DarkMagenta "Generating function reference documents..."
    Import-Module PlatyPS
    $Module = Import-Module $ProjectRoot/vester/vester.psd1 -PassThru
    $null = New-MarkdownHelp -Module $env:BHProjectName -OutputFolder $CompilingFolder/reference/functions
    $FunctionReferenceReadmePath = "$CompilingFolder/reference/functions/readme.md "
    $FunctionReferenceReadmeValue = @(
        "---"
        "Module Name: $($Module.Name)"
        "Module Guid: $($Module.Guid)"
        "Help Version: $($Module.Version)"
        "Locale: en-US"
        "---"
        "# Function Reference"
        "The following chapters provide the online help for the public functions of the $env:BHProjectName module"
        "$(Get-Command -Module $env:BHProjectName | ForEach-Object {
            $Info = Get-Help $PSItem
            "# [``$($Info.Name)``]($($Info.Name).md)`r`n$($Info.Synopsis)`r`n"
        })"
    )
    $null = New-Item -Path $FunctionReferenceReadmePath -Value ($FunctionReferenceReadmeValue -join("`r`n"))
    Write-Host -ForegroundColor DarkMagenta "Generating test reference documents..."
    ForEach ($Test in (Get-ChildItem -Path $ProjectRoot/Vester/Tests -Recurse -File)) {
        [string]$Category = $(Split-Path -Path (Split-Path -Path $Test.FullName -Parent) -Leaf)
        . $Test.FullName
        $DocumentPath = "$CompilingFolder/reference/tests/$Category/$($Title.replace(' ','-').replace(':','')).md"
        If (!(Test-Path -Path (Split-Path $DocumentPath -Parent))) {
            $null = New-Item -Path "$(Split-Path $DocumentPath -Parent)/readme.md" -Value "# $Category Tests`r`nSee the following chapters for more information." -Force
        }
        If (!(Test-Path -Path $DocumentPath)) {
            $null = New-Item -Path $DocumentPath -Value "# $Title`r`n$Description" -Force
        }
        @(
            "`r`n## Discovery Code`r`n" + '```powershell' + "$Actual" + '```'
            "`r`n## Remediation Code`r`n" + '```powershell' + "$Fix" + '```'
        )  | Add-Content -Path $DocumentPath
    }
    Push-Location -Path $CompilingFolder
    Write-Host -ForegroundColor DarkMagenta "Generating summary file..."
    book sm
    Write-Host -ForegroundColor DarkMagenta "Installing gitbook plugins..."
    gitbook install
    Pop-Location
}

Task GenerateSite -depends Compile {
    gitbook build $CompilingFolder $OutputSitePath
}

Task GeneratePdf -depends Compile {
    gitbook pdf $CompilingFolder $OutputPdfPath
}

Task LivePreview -depends Compile {
    Push-Location -Path $CompilingFolder
    gitbook serve
    Pop-Location
}