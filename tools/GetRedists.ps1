
<#PSScriptInfo

.VERSION 4.1

.GUID 03c695c0-bf45-4257-8156-89310e951140

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2023 Jonathan E. Brickman

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
# v5.0                                                                #
#######################################################################

#
# by Jonathan E. Brickman
#
# Retrieves and installs all of the Microsoft redistributable libraries
# currently being supported, using the excellent VcRedist package.
#
# Copyright 2020 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#
# GetRedists is entirely dependent upon VcRedist:
# https://docs.stealthpuppy.com/vcredist/function-syntax/get-vclist
# for which profound gratitude is!!!
#
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
    } else {
    "Not running as elevated.  Starting elevated shell."
    Start-Process powershell -WorkingDirectory $PWD.Path -Verb runAs -ArgumentList "-noprofile -noexit -file $PSCommandPath"
    return "Done. This one will now exit."
    ""
    }

# Sets TLS version.  Necessary for some situations.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

	Write-Progress -Activity "Get Microsoft Redistributables" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
	# Write-Progress is not compatible with some remote shell methods.

}

'Preparing Powershell environment...'

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force > $null

ShowProgress("Preparing Powershell environment...","Setting up to use Powershell Gallery...")

Install-PackageProvider -Name NuGet -Force -ErrorAction 'SilentlyContinue' > $null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
If (Get-InstalledModule -Name PsWindowsUpdate -ErrorAction 'SilentlyContinue') {
	Update-Module -Name PSWindowsUpdate -Force
} Else {
	Install-Module -Name PSWindowsUpdate -Force
}
Import-Module PSWindowsUpdate

ShowProgress("Preparing Powershell environment...","Checking and preparing module VcRedist...")

# Install or update module VcRedist
If (Get-InstalledModule -Name VcRedist -ErrorAction 'SilentlyContinue') {
	Update-Module -Name VcRedist -Force
} Else {
	Install-Module -Name VcRedist -AllowClobber -Scope CurrentUser -Force
}

# Import VcRedist to this session
Import-Module -Name VcRedist

if ($False -eq (Test-Path C:\VcRedist -PathType Container)) {
	New-Item C:\VcRedist -ItemType Directory | Out-Null 
	}
	
''

'Getting list of currently installed redistributables...'
	
ShowProgress("Getting list of currently installed redistributables...","")
$InstalledRedists = Get-InstalledVcRedist

'Getting list of currently available and supported redistributables...'
''

ShowProgress("Getting list of currently available and supported redistributables...","")
$AvailableRedists = Get-VcList

ShowProgress("Checking and installing/upgrading as needed...","")

# Create blank array of redists to install
$RedistsToGet = @()

# Initialize...
$NothingMissing = $True

# Cycle through all available redists
# Using .ProductCode not .Version, .ProductCode will eliminate false downloads
ForEach ($OnlineRedist in $AvailableRedists) {

	'Checking: ' + $OnlineRedist.Name + '...'
	
	# Cycle through all redists currently installed,
	# checking to see if the available one being checked is there,
	# and if not, add it to the array of those to be installed.
	
	$IsInstalled = $False
	
	ForEach ($LocalRedist in $InstalledRedists) {
		If ($OnlineRedist.ProductCode -eq $LocalRedist.ProductCode) {
			'Already installed.'
			""
			$IsInstalled = $True
			break
			}
		}
	If ($IsInstalled -eq $False) {
		'Needed.'
		""
		$RedistsToGet += ,$OnlineRedist
		$NothingMissing = $False
		}
	}
	
If ($NothingMissing -eq $True)
	{
	"No VC++ redistributables missing."
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
Install-VcRedist -Verbose -VcList $RedistsToGet -Path C:\VcRedist | ft

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

