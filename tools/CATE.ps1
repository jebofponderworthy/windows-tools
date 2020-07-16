
<#PSScriptInfo

.VERSION 5.1

.GUID f842f577-3f42-4cb0-91e7-97b499260a21

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2020 Jonathan E. Brickman

.TAGS 

.LICENSEURI https://opensource.org/licenses/BSD-3-Clause

.PROJECTURI https://github.com/jebofponderworthy/windows-tools

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
CATE - Clean All Temp Etc
Cleans temporary files and folders from all standard user temp folders,
system profile temp folders, and system temp folders (they are not the same!);
also clears logs, IE caches, Firefox caches, Chrome caches, Ask Partner Network data,
Adobe Flash caches, Java deployment caches, and Microsoft CryptnetURL caches.

#> 

































































































<#

.DESCRIPTION 
Clean All Temp Etc - cleans temporary files and folders from all standard user and system temp folders, clears logs, and more

#>

Param()


#############################
# CATE: Clean All Temp Etc. #
#############################

#
# by Jonathan E. Brickman
#
# Cleans temp files from all user profiles and
# several other locations.  Also clears log files.
#
# Copyright 2018 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

# Self-elevate if not already elevated.

"*************************"
"   Clean All Temp Etc.   "
"*************************"

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

# Get environment variables etc.

$envTEMP = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$envTMP = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$envSystemRoot = $env:SystemRoot
$envProgramData = $env:ProgramData

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$originalLocation = Get-Location

$CATEStatus = ""

# Get initial free disk space.

function DriveSpace {
	param( [string] $strComputer)

	# Does the server responds to a ping (otherwise the WMI queries will fail)

	$result = Get-CimInstance -query "select * from win32_pingstatus where address = '$strComputer'"
	if ($result.protocoladdress) {

		$totalFreeSpace = 0

		# Get the disks for this computer, and total the free space
		Get-CimInstance -Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" | ForEach-Object {
			$totalFreeSpace = $totalFreeSpace + $_.freespace
		    }

		return $totalFreeSpace
	    }
    }

function RptDriveSpace {
    param( $rawDriveSpace )

    $MBDriveSpace = [double]$rawDriveSpace / 1024000.0
    $truncatedDriveSpace = [double]([math]::Truncate($MBDriveSpace))
    $fracDriveSpace = [double]$MBDriveSpace - [double]$truncatedDriveSpace

    return "{0:N0}{1:.###}" -f $truncatedDriveSpace, $fracDriveSpace
    }

$initialFreeSpace = DriveSpace("localhost")
$strOut = RptDriveSpace( $initialFreeSpace )
$strOut = "Initial free space (all drives): " + $strOut + " megabytes."
Write-Output $strOut

""
"Working..."
""

# Here is an external variable to contain the "Status" text
# for progress reporting.

$CATEStatus = "Working..."

# Now we set up an array containing folders to be checked for and
# cleaned out if present, for every profile.

$foldersToClean = @(
    "\Local Settings\Temp",
    "\Local Settings\Temporary Internet Files",
    "\AppData\Local\Microsoft\Windows\Temporary Internet Files",
    "\AppData\Local\Microsoft\Windows\INetCache\IE",
    "\AppData\Local\Microsoft\Windows\INetCache\Low\Content.IE5",
    "\AppData\Local\Microsoft\Windows\INetCache\Low\Flash",
    "\AppData\Local\Microsoft\Windows\INetCache\Content.Outlook",
    "\AppData\Local\Google\Chrome\User Data\Default\Cache",
    "\AppData\Local\AskPartnerNetwork",
	"\AppData\Local\Temp",
    "\Application Data\Local\Microsoft\Windows\WER",
    "\Application Data\Adobe\Flash Player\AssetCache",
    "\Application Data\Sun\Java\Deployment\cache",
    "\Application Data\Microsoft\CryptnetUrlCache"
    )

$ffFoldersToClean = @(
	"cache",
	"cache2\entries",
	"thumbnails",
	"cookies.sqlite",
	"webappstore.sqlite",
	"chromeappstore.sqlite"
	)

# A quasiprimitive for PowerShell-style progress reporting.

function ShowCATEProgress {
	param( [string]$reportStatus, [string]$currentOp )

    Write-Progress -Activity "Clean All Temp Etc" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }

# Rewriting the delete primitives, as effectively as possible, without inline C#.
#
# For decent speed, need to use parallelism of some sort.
# C# had it, but gets security-flagged.
# Powershell 7 is getting it.  But that's a long ways off being available by default.
#
# Using ROBOCOPY's multitasking instead.  ROBOCOPY does not, reportedly, suffer from
# the maximum line length situation and others which requires -Literalpath in some coding.

$randomFolderName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$envUserProfile = $env:UserProfile
$blankFolder = $envUserProfile + '\' + $randomFolderName
New-Item $blankFolder -Force -ItemType Container
If ( !(Test-Path $blankFolder -PathType Container) )
		{ 
		Write-Host 'Error: Cannot create reference folder for delete primitive'
		Exit 
		}
		
# CATE-Delete is a functional recursive primitive,
# useful for absolute deletes of items and trees, and 
# also callable for more selective uses

# Still starting with non-literal paths, because ROBOCOPY requires them,
# and because of recursion.

# CATE-DELETE has to ignore symbolic links and junctions and the like
# if it's asked to touch them.  Hence, Test-ReparsePoint() below.

function Test-ReparsePoint([string]$literalPath) {
	$file = Get-Item $literalPath -Force -ErrorAction SilentlyContinue
	return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
	}

function CATE-Delete {
	param( [string]$deletePath )
	
	$literalDeletePath = '\\?\' + $deletePath
	
	# If the folder isn't there, we're done
	If ( !(Test-Path -LiteralPath $literalDeletePath -PathType Container) )
		{ Return }
	
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($literalDeletePath))
		{ Return }
	
	ShowCATEProgress $CATEStatus $deletePath

	# First try to remove simply, which includes non-containers
	# Do this using literal paths because it works more often
	#
	Remove-Item -LiteralPath $literalDeletePath -Force -Recurse *> $null
	
	# If it's gone, we're done.
	If ( !(Test-Path -LiteralPath $literalDeletePath -PathType Container) )
		{ Return }
	
	# If it's not, delete all contents with ROBOCOPY, 10 threads.
	#
	ROBOCOPY $blankFolder $deletePath /MIR /R:1 /W:1 /MT:10 *> $null
	
	# If there's anything left inside it, call this whole function recursively, 
	# on all of the contents.
	Get-ChildItem -Recurse -LiteralPath $literalDeletePath -Name -Force -ErrorAction SilentlyContinue | ForEach-Object {
		CATE-Delete ($deletePath + '\' + $_)
		}
	}

function CATE-Delete-Folder-Contents {
	param( [string]$deletePath )
	
	$literalDeletePath = '\\?\' + $deletePath

	# If the folder isn't there, we're done
	If ( !(Test-Path -LiteralPath $literalDeletePath -PathType Container) )
		{ Return }
		
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($literalDeletePath))
		{ Return }
		
	ShowCATEProgress $CATEStatus $deletePath
		
	# First try to wipe the inside of the folder simply.
	# ROBOCOPY is current default method, for parallelism.
	ROBOCOPY $blankFolder $deletePath /MIR /R:1 /W:1 /MT:10 *> $null
	
	# Now try to delete everything left inside, using CATE-Delete.
	Get-ChildItem -LiteralPath $literalDeletePath -Name -Force -ErrorAction SilentlyContinue | ForEach-Object {
		CATE-Delete ($deletePath + '\' + $_)
		}
	}

function CATE-Delete-Files-Only {
	param( [string]$deletePath, [string]$wildCard )
	
	$literalDeletePath = '\\?\' + $deletePath
	
	# If the folder isn't there, we're done
	If ( !(Test-Path -LiteralPath $literalDeletePath -PathType Container) )
		{ Return }
		
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($literalDeletePath))
		{ Return }

	ShowCATEProgress $CATEStatus ($deletePath + '\' + $wildCard)
	
	ROBOCOPY $blankFolder $deletePath $wildCard /MIR /R:1 /W:1 /MT:10 *> $null
	}
		
# Loop through all of the paths for all user profiles
# as recorded in the registry, and delete temp files.

# Outer loop enumerates all user profiles
$ProfileList = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
$ProfileCount = $ProfileList.Count
$ProfileNumber = 1
$ProfileList | ForEach-Object {
    $profileItem = Get-ItemProperty $_.pspath
    $CATEStatus = "Working on (profile " + $ProfileNumber + "/" + $ProfileCount + ") " + $profileItem.ProfileImagePath + " ..."
    $ProfileNumber += 1

    # This loop enumerates all non-Firefox folder subpaths within profiles to be cleaned
    ForEach ($folderSubpath in $foldersToClean) {
        $ToClean = $profileItem.ProfileImagePath + $folderSubpath
        If (Test-Path $ToClean -PathType Container) {
            # If the actual path exists, clean it
            CATE-Delete-Folder-Contents $ToClean
            }
        }
		
	# These loops handle Firefox and multiple FF profiles if they exist
	$ffProfilePath = $profileItem.ProfileImagePath + '\AppData\Local\Mozilla\Firefox\Profiles\'
	If (Test-Path $ffProfilePath) {
		Get-ChildItem -Path $ffProfilePath -ErrorAction SilentlyContinue | ForEach-Object {
			$ffProfilePath = Get-ItemProperty $_.pspath
		
			ForEach ($subPath in $ffFoldersToClean) {
				$ToClean = "$ffProfilePath\$subPath"
				CATE-Delete-Folder-Contents $ToClean
				}
			}
		}
	$ffProfilePath = $profileItem.ProfileImagePath + '\AppData\Roaming\Mozilla\Firefox\Profiles\'
	If (Test-Path $ffProfilePath) {
		Get-ChildItem -Path $ffProfilePath -ErrorAction SilentlyContinue | ForEach-Object {
			$ffProfilePath = Get-ItemProperty $_.pspath
		
			ForEach ($subPath in $ffFoldersToClean) {
				$ToClean = "$ffProfilePath\$subPath"
				CATE-Delete-Folder-Contents $ToClean
				}
			}
		}

    # A subpath to be eliminated altogether, also present in the $foldersToClean list above
    CATE-Delete ($profileItem.ProfileImagePath + '\AppData\Local\AskPartnerNetwork')
    }

# Now empty certain folders

$CATEStatus = "Working on other folders ..."

CATE-Delete-Folder-Contents $envTEMP

CATE-Delete-Folder-Contents $envTMP

CATE-Delete-Folder-Contents ($envSystemRoot + "\Temp")

CATE-Delete-Folder-Contents ($envSystemRoot + "\system32\wbem\logs")

CATE-Delete-Folder-Contents ($envSystemRoot + "\system32\Debug")

CATE-Delete-Folder-Contents ($envSystemRoot + "\PCHEALTH\ERRORREP\UserDumps")

CATE-Delete-Folder-Contents ($envProgramData + "\Microsoft\Windows\WER\ReportQueue")

# And then delete log files by wildcard, recursing through folders

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.log'

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.EVM'

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.EVM.*'

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.etl'

CATE-Delete-Files-Only ($envSystemRoot + '\Logs') '*.log'

CATE-Delete-Files-Only ($envSystemRoot + '\Logs') '*.etl'

CATE-Delete-Files-Only ($envSystemRoot + '\inf') '*.log'

CATE-Delete-Files-Only ($envSystemRoot + '\Prefetch') '*.pf'

""
""

$strOut = RptDriveSpace( $initialFreeSpace )
$strOut = "Initial free space (all drives): " + $strOut + " megabytes."
Write-Output $strOut

$finalFreeSpace = DriveSpace("localhost")
$strOut = RptDriveSpace( $finalFreeSpace )
$strOut = "Final free space (all drives):   " + $strOut + " megabytes."
Write-Output $strOut

$freedSpace = $finalFreeSpace - $initialFreeSpace
$strOut = RptDriveSpace ( $freedSpace )
$strOut = "Difference: " + $strOut + " megabytes."
Write-Output ""
Write-Output $strOut
Write-Output ""

Remove-Item $blankFolder -Force -Recurse -ErrorAction SilentlyContinue
Set-Location $originalLocation

ShowCATEProgress 'Pausing for report...' ''

Start-Sleep 7

exit

# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called
# the New BSD License or the Modified BSD License.
# See also the 2-clause BSD License.

# Copyright 2017 Jonathan E. Brickman

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
# CONTRIBUTORS AS IS, AND ANY EXPRESS OR IMPLIED WARRANTIES,
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

