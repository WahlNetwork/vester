function New-VesterTest {
    <#
    .SYNOPSIS
    Create Vester Test files based on Input Object details.
    
    .DESCRIPTION
    New-VesterTest takes the input object and creates *.Vester.ps1 files. These
    Files are consumed by the 'Get-VesterTest' function. It will verify that each
    test has the correct items for successful use in Vester. Ideally the object 
    will have Name,Value,Description properties.

    "Get-Help New-VesterTest -Examples" for more details.
    
    .EXAMPLE
    Get-AdvancedSetting -Entity 192.168.2.200 | where {$_.name -match "SSO"} | New-VesterTest -Prefix VC -Path "C:\Temp\testFiles\"

    .EXAMPLE
    Get-AdvancedSetting -Entity 192.168.2.200 | where {$_.name -match "SSO"} | New-VesterTest -Prefix VC -Path "C:\Temp\testFiles\" -verbose
    Outputs Verbose logging 

    .EXAMPLE
    $CreationReport = Get-AdvancedSetting -Entity 192.168.2.200 | where {$_.name -match "SSO"} | New-VesterTest -Prefix VC -Path "C:\Temp\testFiles\"
    Captures the output object

    .EXAMPLE
    New-VesterTest -Data $vCenterAdvSettings -Prefix VC -Path "C:\Temp\testFiles\
    First create an object with a PowerCLI command like so:
    "$vCenterAdvSettings = Get-AdvancedSetting -Entity 192.168.2.200 | where {$_.name -match "SSO"}"

    .INPUTS
    [System.Object]
    Accepts piped input(s) for parameter -Data.

    .INPUTS
    [System.String]
    Accepts piped input(s) for parameter -Path.  
    
    .INPUTS
    [System.String]
    Accepts piped input(s) for parameter -Prefix.    
    
    .OUTPUTS
    [PSCustomObject]
    TestFile Creation Report

    .NOTES
    "Get-Help New-VesterTest -Examples" for more details.

    .LINK
    https://wahlnetwork.github.io/Vester

    .LINK
    https://github.com/WahlNetwork/Vester    
    #>
    [CmdletBinding()]
    param (
        # The folder path to crete Vester.ps1 files in.
        [Parameter(ValueFromPipeline = $true)]
        [ValidateScript({
            [bool](($_.PSobject.Properties.name -match "Name") -and ($_.PSobject.Properties.name -match "value"))
        })]
        [Object[]]$Data,

        # The folder path to crete Vester.ps1 files in.
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string[]]$Path,

        # Prefix to the Vester Test file name.
        [string[]]$Prefix 
    )

    BEGIN {
        # Create an empty object to hold report data.
        $NewTestFileReport = @()
    } #begin

    PROCESS {
        # Loop through each TestSetting in the Data Object
        foreach($TestSetting in $Data) {
            Write-Verbose "Starting Process to create a new Test Setting file."
            # Gather the information for this TestSetting
            $Name = $TestSetting.name
            $value = $TestSetting.value
            $valueType = $value.getType().name
            $TestDescription = $TestSetting.description
            
            # Validate if the Description is Empty
            if ($TestDescription -eq ""){
                Write-Verbose "The TestDescription is empty, using the name as description."
                $TestDescription = $name
            }
            # Replace any NonDesired Characters in the name to correctly name the Output File and Desired Value.
            # Characters Currently include '. : [ ] /'
            if($Name -match ".") {
                $DesiredValueName = $name -replace ("\.","")
                Write-Verbose "The Desired value has been updated to $DesiredValueName"               
            } else {
                $DesiredValueName = $name
                Write-Verbose "Using the name as the DesiredValueName."
            }
            if($DesiredValueName -match " ") {
                $DesiredValueName = $DesiredValueName -replace ('\s','')
                Write-Verbose "The Desired value has been updated to $DesiredValueName"  
            }
            if($DesiredValueName -match "-") {
                $DesiredValueName = $DesiredValueName -replace ("-","")
                Write-Verbose "The Desired value has been updated to $DesiredValueName"  
            }            
            # Skip creating the file if we have a special character or the example value is blank
            if(($Name -match ":") -or ($Name -match [regex]::Escape("[")) -or ($Name -match [regex]::Escape("]")) -or ($Name -match '/') -or ($value -eq "")) {
                Write-Verbose "The TestName has a special Character, or example value was empty, not creating test file."
                $currentTestSetting = New-Object System.Object
                $currentTestSetting | Add-Member -type NoteProperty -Name TestSetting -Value $Name
                $currentTestSetting | Add-Member -Type NoteProperty -Name FileCreated -Value $false
                $currentTestSetting | Add-Member -Type NoteProperty -Name FilePath -Value $null
                $NewTestFileReport += $currentTestSetting
                continue 
            }                                                                              
            
            # Build the Output File path for this TestSetting
            $NewTestFile = "$Path\$Prefix-$DesiredValueName.Vester.ps1"
            # Useful information when verbose option is selected.
            write-Verbose "The TestSetting is $name"
            write-Verbose "Example value is $value"
            write-Verbose "The ValueType is $valueType"
            write-Verbose "The description is $TestDescription"
            write-Verbose "The Desired Value Name is $DesiredValueName"
            write-Verbose "The new File name will be $NewTestFile"

            # Create the new file, using ZZZ as a placeholder to be replace by a $.
            Write-Verbose "Creating new Test file now."
            "# Test file for the Vester module - https://github.com/WahlNetwork/Vester" | out-file -FilePath $NewTestFile -Append
            "# Called via Invoke-Pester VesterTemplate.Tests.ps1" | out-file -FilePath $NewTestFile -Append
            "" | out-file -FilePath $NewTestFile -Append
            "# Test title, e.g. 'DNS Servers'" | out-file -FilePath $NewTestFile -Append
            "ZZZTitle = '$name'" | out-file -FilePath $NewTestFile -Append
            "" | out-file -FilePath $NewTestFile -Append
            "# Test description: How New-VesterConfig explains this value to the user" | out-file -FilePath $NewTestFile -Append
            "ZZZDescription = '$TestDescription'" | out-file -FilePath $NewTestFile -Append
            "" | out-file -FilePath $NewTestFile -Append
            "# The config entry stating the desired values" | out-file -FilePath $NewTestFile -Append
            "ZZZDesired = ZZZcfg.vcenter.$DesiredValueName" | out-file -FilePath $NewTestFile -Append
            "" | out-file -FilePath $NewTestFile -Append
            "# The test value's data type, to help with conversion: bool/string/int" | out-file -FilePath $NewTestFile -Append
            "ZZZType = '$valueType'" | out-file -FilePath $NewTestFile -Append
            "" | out-file -FilePath $NewTestFile -Append
            "# The command(s) to pull the actual value for comparison" | out-file -FilePath $NewTestFile -Append
            "# ZZZObject will scope to the folder this test is in (Cluster, Host, etc.)" | out-file -FilePath $NewTestFile -Append
            "[ScriptBlock]ZZZActual = {" | out-file -FilePath $NewTestFile -Append
            "    (Get-AdvancedSetting -Entity ZZZObject -Name `"$name`").Value" | out-file -FilePath $NewTestFile -Append
            "}" | out-file -FilePath $NewTestFile -Append
            "" | out-file -FilePath $NewTestFile -Append
            "# The command(s) to match the environment to the config" | out-file -FilePath $NewTestFile -Append
            "# Use ZZZObject to help filter, and $Desired to set the correct value" | out-file -FilePath $NewTestFile -Append
            "[ScriptBlock]ZZZFix = {" | out-file -FilePath $NewTestFile -Append
            "    Get-AdvancedSetting -Entity ZZZObject -Name `"$name`" |" | out-file -FilePath $NewTestFile -Append
            "        Set-AdvancedSetting -value ZZZDesired -Confirm:ZZZfalse -ErrorAction Stop" | out-file -FilePath $NewTestFile -Append
            "}" | out-file -FilePath $NewTestFile -Append
        
            # Replace Value with $
            Write-Verbose "Attempting to replace ZZZ with a '$'."
            $replaceValue = '$'
            (Get-Content $NewTestFile) -replace "ZZZ","$replaceValue" | Set-Content $NewTestFile
            $currentTestSetting = New-Object System.Object
            $currentTestSetting | Add-Member -type NoteProperty -Name TestSetting -Value $Name
            $currentTestSetting | Add-Member -Type NoteProperty -Name FileCreated -Value $true
            $currentTestSetting | Add-Member -Type NoteProperty -Name FilePath -Value $NewTestFile
            $NewTestFileReport += $currentTestSetting
        } #foreach

    } #process

    END {
        Write-Verbose "New Test Files:"
        $NewTestFileReport
    } #end
}