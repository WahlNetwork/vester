#Requires -Version 4 -Modules Pester

$here = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -replace "Tests\\Function", "Vester\Public"
$priv = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -replace "Tests\\Function", "Vester\Private"
$sut = (Split-Path -Path $MyInvocation.MyCommand.Path -Leaf) -replace "\.Tests", ""
#Bring function into execution scope
. "$here\$sut"

#Dot-Source supporting private functions
#We will mock this functions later, in order to do that, they first need to be imported.
. "$priv\Get-VesterChildItem.ps1"
. "$priv\Extract-VestDetails.ps1"

$TestPath = Get-Item -Path ( (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -replace "Tests\\Function", "Vester\Tests\Cluster" )
$DirectoryTestsPath = Get-Item -Path ((Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -replace "Tests\\Function", "Vester\Tests")

Describe -Name 'Get-VesterTest unit tests' -Tag 'unit' -Fixture {
	Context -Name "Error Checking" -Fixture {
		It -name "Path with no tests show throw error" -test {
			{Get-VesterTest -Path $env:Temp} | Should -Throw
		}#It
		Mock -CommandName Get-VesterChildItem -MockWith {
			Get-ChildItem -Path $TestPath
		}
		Mock -CommandName Extract-VestDetails -MockWith {
			[PSCustomObject]@{
				# Add a custom type name for this object
				# Used with DefaultDisplayPropertySet
				Name           = "Sample Output"
				Scope          = "Global"
				FullName       = "Fullname"
				Title          = "Head of Potatoes"
				Description    = "The best description in history"
				Recommendation = "Call your mother more often."
				Desired        = "Better mock data"
				Type           = "Aquarius"
				Actual         = "Pisces"
				Fix            = "Cetus"
			}
		}
		It -name "Path with only tests show not throw error" -test {
			{Get-VesterTest -Path $TestPath} | Should -Not -Throw
		}#It
		It -name "Path with only tests should return data" -test {
			Get-VesterTest -Path $TestPath | Should -Not -BeNullOrEmpty
		}
		It -name "Path with tests in sub-directories show not throw error" -test {
			{Get-VesterTest -Path $DirectoryTestsPath} | Should -Not -Throw
		}#It
		It -name "Path with tests  in sub-directories should return data" -test {
			Get-VesterTest -Path $DirectoryTestsPath | Should -Not -BeNullOrEmpty
		}
	}#Context error checking
}#Describe unit testing
