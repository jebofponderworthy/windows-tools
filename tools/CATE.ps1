
<#PSScriptInfo

.VERSION 7.3

.GUID f842f577-3f42-4cb0-91e7-97b499260a21

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2024 Jonathan E. Brickman

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
# Copyright 2023 Jonathan E. Brickman
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
    } else {
    "Not running as elevated.  Starting elevated shell."
    Start-Process powershell -WorkingDirectory $PWD.Path -Verb runAs -ArgumentList "-noprofile -noexit -file $PSCommandPath"
    return "Done. This one will now exit."
    ""
    }

# Get environment variables etc.

$envTEMP = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$envTMP = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$envSystemRoot = $env:SystemRoot
$envProgramData = $env:ProgramData
$envProgramFiles = $env:ProgramFiles
$envProgramFilesx86 = ${env:ProgramFiles(x86)}
$envSystemDrive = $env:SystemDrive

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
	"\AppData\Local\Google\Chrome\User Data\Default\Code Cache\js",
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

# A quasiprimitive for progress reporting.

function ShowCATEProgress {
	param( [string]$reportStatus, [string]$currentOp )

    try {
		Write-Progress -Activity "Clean All Temp Etc" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
	}
	catch {
		Write-Host "Clean All Temp Etc: $reportStatus $currentOp"
	}
	
	# Write-Progress is not compatible with some remote shell methods.
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
New-Item $blankFolder -Force -ItemType Container | Out-Null
If ( !(Test-Path $blankFolder -PathType Container -ErrorAction SilentlyContinue) )
		{ 
		Write-Host 'Error: Cannot create reference folder for delete primitive'
		Exit 
		}
		
# CATE-Delete is a functional recursive primitive,
# useful for absolute deletes of items and trees, and 
# also callable for more selective uses

# There is a lot of question about \\? path syntax.
# It appears to not work at all before Windows 10, in Powershell.
# -LiteralPath does not refer to this.  Not using \\? syntax for now.

# CATE-DELETE has to ignore symbolic links and junctions and the like
# if it's asked to touch them.  Hence, Test-ReparsePoint() below.

function Test-ReparsePoint([string]$literalPath) {
	$file = Get-Item $literalPath -Force -ErrorAction SilentlyContinue
	return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
	}

function CATE-Delete {
	param( [string]$deletePath )
	
	# If the folder isn't there or we can't touch it, we're done
	try {
		$retval = Test-Path -LiteralPath $deletePath -PathType Container -ErrorAction SilentlyContinue
		}
	catch
		{
		"Cannot access path: $deletePath"
		Return
		}
	
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($deletePath))
		{ Return }
	
	ShowCATEProgress $CATEStatus $deletePath

	# First try to remove simply, which includes non-containers
	# Do this using literal paths because it works more often
	#
	Remove-Item -LiteralPath $deletePath -Force -Recurse *> $null
	
	# If it's gone, we're done.
	If ( !(Test-Path -LiteralPath $deletePath -PathType Container -ErrorAction SilentlyContinue) )
		{ Return }
	
	# If it's not, delete all contents with ROBOCOPY, 10 threads.
	#
	ROBOCOPY $blankFolder $deletePath /MIR /R:1 /W:1 /MT:10 *> $null
	
	# If there's anything left inside it, call this whole function recursively, 
	# on all of the contents.
	Try {
		Get-ChildItem -Recurse -LiteralPath $deletePath -Name -Force -ErrorAction SilentlyContinue | ForEach-Object {
			CATE-Delete ($deletePath + '\' + $_)
			}
		}
	Catch
		{
		"Cannot recurse path: $deletePath"
		Return
		}
	}

function CATE-Delete-Folder-Contents {
	param( [string]$deletePath )
	
	# If the folder isn't there or we can't touch it, we're done
	try {
		$retval = Test-Path -LiteralPath $deletePath -PathType Container -ErrorAction SilentlyContinue
		}
	catch
		{
		"Cannot access path: $deletePath"
		Return
		}
	
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($deletePath))
		{ Return }
		
	ShowCATEProgress $CATEStatus $deletePath
	"Counting contents of $deletepath ..."
	# $file_count = [System.IO.Directory]::GetFiles("$deletepath", "*").Count
	try {
		$file_count = (Get-ChildItem -File -Recurse $deletepath -ErrorAction SilentlyContinue | Measure-Object).Count
		}
	catch
		{
		"Access denied: $deletepath"
		return
		}
	"Deleting $file_count items ..."
		
	# First try to wipe the inside of the folder simply.
	# ROBOCOPY is current default method, for parallelism.
	ROBOCOPY $blankFolder $deletePath /MIR /R:1 /W:1 /MT:10 /NFL /NDL /NJH /NJS /NC /NS /NP *> $null
	
	# Now try to delete everything left inside, using CATE-Delete.
	Get-ChildItem -LiteralPath $deletePath -Name -Force -ErrorAction SilentlyContinue | ForEach-Object {
		CATE-Delete ($deletePath + '\' + $_)
		}
	""
	}

function CATE-Delete-Files-Only {
	param( [string]$deletePath, [string]$wildCard )
	
	# If the folder isn't there or we can't touch it, we're done
	try {
		$retval = Test-Path -LiteralPath $deletePath -PathType Container -ErrorAction SilentlyContinue
		}
	catch
		{
		"Cannot access path: $deletePath"
		Return
		}
	
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($deletePath))
		{ Return }
		
	ShowCATEProgress $CATEStatus ($deletePath + '\' + $wildCard)
	"Counting $wildCard in $deletepath ..."
	$filepath = $deletePath
	$filetype = $wildCard
	# $file_count = [System.IO.Directory]::GetFiles("$filepath", "$filetype").Count
	$file_count = (Get-ChildItem -File "$filepath\$filetype" -ErrorAction SilentlyContinue | Measure-Object).Count
	"Deleting $file_count files ..."
	
	ROBOCOPY $blankFolder $deletePath $wildCard /MIR /R:1 /W:1 /MT:10 /NFL /NDL /NJH /NJS /NC /NS /NP *> $null
	""
	}
	
function Replace-Numbered-Temp-Folders {
	param( [string]$topPath )
	
	New-Item -Path ($topPath + '\1') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\2') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\3') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\4') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\5') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\6') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\7') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\8') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path ($topPath + '\9') -ItemType directory -Force -ErrorAction SilentlyContinue | Out-Null
	}
		
# Loop through all of the paths for all user profiles
# as recorded in the registry, and delete temp files.

# Outer loop enumerates all user profiles
$ProfileList = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
$ProfileCount = $ProfileList.Count
$ProfileNumber = 1
$ProfileList | ForEach-Object {
    $profileItem = Get-ItemProperty $_.pspath
    $CATEStatus = ('Working on (profile ' + $ProfileNumber + '/' + $ProfileCount + ') ' + $profileItem.ProfileImagePath + ' ...')
    $ProfileNumber += 1

    # This loop enumerates all non-Firefox folder subpaths within profiles to be cleaned
    ForEach ($folderSubpath in $foldersToClean) {
        $ToClean = ($profileItem.ProfileImagePath + $folderSubpath)
        If (Test-Path $ToClean -PathType Container -ErrorAction SilentlyContinue) {
            # If the actual path exists, clean it
            CATE-Delete-Folder-Contents $ToClean
            }
        }
		
	# These loops handle Firefox and multiple FF profiles if they exist
	$ffProfilePath = ($profileItem.ProfileImagePath + '\AppData\Local\Mozilla\Firefox\Profiles\')
	If (Test-Path $ffProfilePath -PathType Container -ErrorAction SilentlyContinue) {
		Get-ChildItem -LiteralPath $ffProfilePath -Force -ErrorAction SilentlyContinue | ForEach-Object {
			$ffProfilePath = Get-ItemProperty $_.pspath
		
			ForEach ($subPath in $ffFoldersToClean) {
				$ToClean = "$ffProfilePath\$subPath"
				CATE-Delete-Folder-Contents $ToClean
				}
			}
		}
	$ffProfilePath = ($profileItem.ProfileImagePath + '\AppData\Roaming\Mozilla\Firefox\Profiles\')
	If (Test-Path $ffProfilePath -PathType Container -ErrorAction SilentlyContinue) {
		Get-ChildItem -LiteralPath $ffProfilePath -Force -ErrorAction SilentlyContinue | ForEach-Object {
			$ffProfilePath = Get-ItemProperty $_.pspath
		
			ForEach ($subPath in $ffFoldersToClean) {
				$ToClean = "$ffProfilePath\$subPath"
				CATE-Delete-Folder-Contents $ToClean
				}
			}
		}

    # A subpath to be eliminated altogether, also present in the $foldersToClean list above
    CATE-Delete ($profileItem.ProfileImagePath + '\AppData\Local\AskPartnerNetwork')
	
	# Recreate Windows TEMP folder subpaths, prevents issues in a number of oddball situations
	Replace-Numbered-Temp-Folders ($profileItem.ProfileImagePath + '\AppData\Local\Temp') -Force -ErrorAction SilentlyContinue | Out-Null
}

# Now empty certain folders

$CATEStatus = "Working on other folders ..."

"Clearing environment folder TEMP :"
CATE-Delete-Folder-Contents $envTEMP
Replace-Numbered-Temp-Folders ($envTEMP) -Force -ErrorAction SilentlyContinue | Out-Null

"Clearing environment folder TMP :"
CATE-Delete-Folder-Contents $envTMP
Replace-Numbered-Temp-Folders ($envTMP) -Force -ErrorAction SilentlyContinue | Out-Null

"Clearing $envSystemRoot\Temp :"
CATE-Delete-Folder-Contents ($envSystemRoot + "\Temp")
Replace-Numbered-Temp-Folders ($envSystemRoot + "\Temp") -Force -ErrorAction SilentlyContinue | Out-Null

CATE-Delete-Folder-Contents ($envSystemRoot + "\system32\wbem\logs")

CATE-Delete-Folder-Contents ($envSystemRoot + "\system32\Debug")

CATE-Delete-Folder-Contents ($envSystemRoot + "\PCHEALTH\ERRORREP\UserDumps")

CATE-Delete-Folder-Contents ($envSystemRoot + "\Downloaded Program Files")

CATE-Delete-Folder-Contents ($envSystemRoot + "\SoftwareDistribution\Download")

CATE-Delete-Folder-Contents ($envSystemRoot + "\LiveKernelReports")

CATE-Delete-Folder-Contents ($envProgramData + "\Microsoft\Windows\WER\ReportQueue")

CATE-Delete-Folder-Contents ($envProgramData + "\WRData")

CATE-Delete-Folder-Contents ($envProgramFilesx86 + "\ITSPlatform\agentcore\download")

# And then delete log files by wildcard, recursing through folders

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.log'

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.EVM'

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.EVM.*'

CATE-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.etl'

CATE-Delete-Files-Only ($envSystemRoot + '\Logs') '*.log'

CATE-Delete-Files-Only ($envSystemRoot + '\Logs') '*.etl'

CATE-Delete-Files-Only ($envSystemRoot + '\inf') '*.log'

CATE-Delete-Files-Only ($envSystemRoot + '\Prefetch') '*.pf'

# A common monitoring log folder

CATE-Delete-Folder-Contents ($envProgramData + '\SAAZOD\ApplicationLog\zSCCLog')

# A very special folder, needing a fast general count
# Modified from this:
# CATE-Delete-Folder-Contents ($envSystemRoot + "\Servicing\LCU")

function CATE-Clear-LCU {
	param( [string]$deletePath )
	
	# If the folder isn't there or we can't touch it, we're done
	try {
		$retval = Test-Path -LiteralPath $deletePath -PathType Container -ErrorAction SilentlyContinue
		}
	catch
		{
		"Cannot access path: $deletePath"
		Return
		}
	
	# If $deletePath is a ReparsePoint, if it is a link or a junction,
	# exit CATE-Delete silently
	If (Test-ReparsePoint($deletePath))
		{ Return }
		
	ShowCATEProgress $CATEStatus $deletePath
	"Counting folders under $deletepath and one more level down ..."
	# $file_count = [System.IO.Directory]::GetFiles("$deletepath", "*").Count
	try {
		$folders_level1 = (Get-ChildItem -Path $deletepath -Directory -ErrorAction SilentlyContinue)
		$foldercount = $folders_level1.Count
		}
	catch 
		{
		"Access denied: $deletepath"
		return
		}
	try {
		foreach ($folder in $folders_level1)
			{
				"Checking LCU subfolder $folder.Name ..."
				$folders_level2 = (Get-ChildItem -Path ($deletepath + '\' + $folder.Name) -Directory -ErrorAction SilentlyContinue)
				$foldercount = ($foldercount + $folders_level2.Count)
			}
		}
	catch
		{
		return
		}
	"Deleting $foldercount folders total..."
		
	# First try to wipe the inside of the folder simply.
	# ROBOCOPY is current default method, for parallelism.
	ROBOCOPY $blankFolder $deletePath /MIR /R:1 /W:1 /MT:10 /NFL /NDL /NJH /NJS /NC /NS /NP *> $null
	
	# Now try to delete everything left inside, using CATE-Delete.
	Get-ChildItem -LiteralPath $deletePath -Name -Force -ErrorAction SilentlyContinue | ForEach-Object {
		CATE-Delete ($deletePath + '\' + $_)
		}
	""
	}

CATE-Clear-LCU ($envSystemRoot + "\Servicing\LCU")


# Clear the Group Policy client-side cache

CATE-Delete-Folder-Contents ($envSystemRoot + '\system32\GroupPolicy')
Remove-Item "HKLM:\Software\Policies\Microsoft" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
Remove-Item "HKCU:\Software\Policies\Microsoft" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
Remove-Item "HKCU:\\Software\Microsoft\Windows\CurrentVersion\Policies" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

# Clear the users' Teams caches, as possible without disruption
Get-ChildItem "C:\Users\*\AppData\Roaming\Microsoft\Teams\*" -directory | 
	Where name -in ('application cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | 
	ForEach{Remove-Item $_.FullName -Recurse -Force -WhatIf}


function Background-Run-For-Five-Minutes-Max {
	param( $MyScript )
	
	$JobGUID = [system.Guid]::NewGuid()

	$elapsedEventHandler = {
		param ([System.Object]$sender, [System.Timers.ElapsedEventArgs]$e)

		($sender -as [System.Timers.Timer]).Stop()
		Unregister-Event -SourceIdentifier $JobGUID
		Write-Host "Job $JobGUID removed by force as it exceeded timeout!"
		Get-Job -Name $JobGUID | Remove-Job -Force
	}

	$timer = New-Object System.Timers.Timer -ArgumentList 300000 #just change the timeout here
	Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $elapsedEventHandler -SourceIdentifier $JobGUID
	$timer.Start()

	Start-Job -ScriptBlock $MyScript -Name $JobGUID
}

# Compact the Windows Update database, if found

Write-Output ''
Write-Output "Setting up background job to compact the Windows Update database, will run 5 minutes max..."
Write-Output ''

$CompactWindowsUpdateDatabase = {
	$wudb = $envSystemRoot + '\SoftwareDistribution\DataStore\DataStore.edb'
	if (Test-Path -Path $wudb -PathType Leaf) {
		Write-Output "Stopping services..."
		Stop-Service wuauserv *> $null
		Stop-Service bits *> $null
		Write-Output "Compacting..."
		& esentutl.exe /d $wudb
		Write-Output "Restarting services..."
		Start-Service wuauserv *> $null
		Start-Service bits *> $null
	}
}
	
Background-Run-For-Five-Minutes-Max $CompactWindowsUpdateDatabase

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

Write-Progress "Done!" -Completed
Write-Progress "Done!" -Completed

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

















