
<#PSScriptInfo

.VERSION 2.6

.GUID 03c695c0-bf45-4257-8156-89310e951140

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2019 Jonathan E. Brickman

.TAGS 

.LICENSEURI https://opensource.org/licenses/BSD-3-Clause

.PROJECTURI https://github.com/jebofponderworthy/windows-tools

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
GetRedists
Retrieve, and install/update, all missing VC++ redistributable libraries
currently being supported by Microsoft, using the excellent
VcRedist module.

.PRIVATEDATA 

#> 





































<#

.DESCRIPTION 
GetRedists - Get all current Microsoft VC++ redistributables

#>

Param()


#######################################################################
# GetRedists                                                          #
#######################################################################

#
# by Jonathan E. Brickman
#
# Retrieves and installs all of the Microsoft redistributable libraries
# currently being supported, using the excellent VcRedist package.
#
# Copyright 2018 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#
# GetRedists is entirely dependent upon VcRedist:
# https://docs.stealthpuppy.com/vcredist/function-syntax/get-vclist
# for which profound gratitude is!!!
#
# Starting with version 2, this script will retrieve the versions
# already installed, and install only the supported versions
# not already installed.
#

""
""
"****************"
"   GetRedists   "
"****************"
""
""

# Items needing work:
# - Command-line option for location of repo folder
# - Error handling; if errors occur at any stage, terminate and print.

# Self-elevate if not already elevated.
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
    "Running elevated; good."
    ""
    }
else {
    "Not running as elevated.  Starting elevated shell."
    Start-Process powershell -WorkingDirectory $PSScriptRoot -Verb runAs -ArgumentList "-noprofile -noexit -file $PSCommandPath"
    return "Done. This one will now exit."
    ""
}

$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

    Write-Progress -Activity "Get Microsoft Redists" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }
	
Function PrepareModule {
	param( [string]$ModuleName )
	
	ShowProgress("Preparing Powershell environment:","Installing " + $ModuleName + " ...")
	Install-Module -Name $ModuleName -Repository PSGallery -Force
	ShowProgress("Preparing Powershell environment:","Importing " + $ModuleName + " ...")
	Import-Module -Name $ModuleName -Force
	}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force > $null

ShowProgress("Preparing Powershell environment:","Preparing PackageProvider NuGet...")

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null

ShowProgress("Preparing Powershell environment...","Setting up to use Powershell Gallery...")

Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

PrepareModule("NuGet")
PrepareModule("VcRedist")

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
		If ($OnlineRedist.Version -eq $LocalRedist.Version) {
			$OnlineRedist.Version + " already installed!"
			""
			$IsInstalled = $True
			break
			}
		}
	If ($IsInstalled -eq $False) {
		$OnlineRedist.Version + " needed."
		""
		$RedistsToGet += ,$OnlineRedist
		$IsInstalled = $True
		}
	}
	
If ($RedistsToGet -eq @())
	{
	"No VC++ redistributables missing!"
	""
	Exit
	}
	
ShowProgress("Retrieving all needed redistributables to repo folder...","")
"Retrieving..."
""
$ListOfDownloads = Get-VcRedist -Verbose -VcList $RedistsToGet -Path C:\VcRedist

ShowProgress("Installing all needed redistributables from repo folder...","")
""
"Installing..."
""
Install-VcRedist -Verbose -VcList $RedistsToGet -Path C:\VcRedist

# The old brute force get-them-all code
#
# ShowProgress("Retrieving all redistributables to repo folder...","")
# Get-VcList | Get-VcRedist -Verbose -Path C:\VcRedist | Out-Null
# ShowProgress("Installing all redistributables from repo folder...","")
# Get-VcList | Install-VcRedist -Verbose -Path C:\VcRedist | Out-Null

ShowProgress("Removing repo folder...","")
Remove-Item C:\VcRedist -Recurse -Force | Out-Null
ShowProgress("Done!","")

# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called
# the AYA>A>??sA??.??oNew BSD LicenseAYA>A>??sA??,A? or AYA>A>??sA??.??oModified BSD LicenseAYA>A>??sA??,A?.
# See also the 2-clause BSD License.

# Copyright 2018 Jonathan E. Brickman

# Redistribution and use in source and binary
# forms, with or without modification, are
# permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the
# above copyright notice, this list of conditions and
# the following disclaimer.

# 2. Redistributions in binary form must reproduce the
# above copyright notice, this list of conditions and
# the following disclaimer in the documentation and/or
# other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the
# names of its contributors may be used to endorse or
# promote products derived from this software without
# specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS AYA>A>??sA??.??oAS ISAYA>A>??sA??,A? AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.























