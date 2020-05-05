$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

    Write-Progress -Activity "Get Microsoft Redists" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }

if ($PSVersionTable.PSVersion.Major -lt 6) {
	# Only do this if PowerShell version less than 6
	ShowProgress("Preparing Powershell environment:","Installing NuGet Package Provider (for VcRedist)...")
	Install-PackageProvider -Name NuGet -Force | Out-Null
	}
ShowProgress("Preparing Powershell environment:","Installing NuGet (for VcRedist)...")
Install-Module -Name NuGet -SkipPublisherCheck -Force
ShowProgress("Preparing Powershell environment:","Importing NuGet (for VcRedist)...")
Import-Module -Name NuGet
ShowProgress("Preparing Powershell environment:","Installing VcRedist...")
Install-Module -Name VcRedist -SkipPublisherCheck -Force
ShowProgress("Preparing Powershell environment:","Importing VcRedist...")
Import-Module -Name VcRedist
ShowProgress("Preparing repo folder...","")
if ($False -eq (Test-Path C:\VcRedist -PathType Container)) {
	New-Item C:\VcRedist -ItemType Directory | Out-Null 
	}
	
ShowProgress("Getting list of currently installed redistributables...","")
$InstalledRedists = Get-InstalledVcRedist
ShowProgress("Getting list of currently available supported redistributables...","")
$AvailableRedists = Get-VcList

ShowProgress("Checking and installing/upgrading as needed...","")

# Create blank array of redists to install
$RedistsToGet = @()

# Cycle through all available redists
ForEach ($OnlineRedist in $AvailableRedists) {

	"Checking version " + $OnlineRedist.Version + "..."
	
	# Cycle through all redists currently installed,
	# checking to see if the available one being checked is there,
	# and if not, add it to the array of those to be installed.
	$IsInstalled = $False
	ForEach ($LocalRedist in $InstalledRedists) {
		If ($LocalRedist.Version -eq $OnlineRedist.Version) {
			$LocalRedist.Version + " already installed!"
			$IsInstalled = $True
			break
			}
		}
	If ($IsInstalled -eq $False) {
		$LocalRedist.Version + " needed."
		$RedistsToGet += ,$OnlineRedist
		}
		
	$IsInstalled = $True
	
	}
	
If ($RedistsToGet -eq @())
	{
	"No VC++ redistributables missing!"
	}
	
Get-VcList | Get-VcRedist -Path C:\VcRedist
