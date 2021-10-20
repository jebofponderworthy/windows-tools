
<#PSScriptInfo

.VERSION 5.7

.GUID f842f577-3f42-4cb0-91e7-97b499260a21

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2021 Jonathan E. Brickman

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
# Copyright 2020 Jonathan E. Brickman
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
		
	# First try to wipe the inside of the folder simply.
	# ROBOCOPY is current default method, for parallelism.
	ROBOCOPY $blankFolder $deletePath /MIR /R:1 /W:1 /MT:10 *> $null
	
	# Now try to delete everything left inside, using CATE-Delete.
	Get-ChildItem -LiteralPath $deletePath -Name -Force -ErrorAction SilentlyContinue | ForEach-Object {
		CATE-Delete ($deletePath + '\' + $_)
		}
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
	
	ROBOCOPY $blankFolder $deletePath $wildCard /MIR /R:1 /W:1 /MT:10 *> $null
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

CATE-Delete-Folder-Contents $envTEMP
Replace-Numbered-Temp-Folders ($envTEMP) -Force -ErrorAction SilentlyContinue | Out-Null

CATE-Delete-Folder-Contents $envTMP
Replace-Numbered-Temp-Folders ($envTMP) -Force -ErrorAction SilentlyContinue | Out-Null

CATE-Delete-Folder-Contents ($envSystemRoot + "\Temp")
Replace-Numbered-Temp-Folders ($envSystemRoot + "\Temp") -Force -ErrorAction SilentlyContinue | Out-Null

CATE-Delete-Folder-Contents ($envSystemDrive + "\$GetCurrent")

CATE-Delete-Folder-Contents ($envSystemRoot + "\system32\wbem\logs")

CATE-Delete-Folder-Contents ($envSystemRoot + "\system32\Debug")

CATE-Delete-Folder-Contents ($envSystemRoot + "\PCHEALTH\ERRORREP\UserDumps")

CATE-Delete-Folder-Contents ($envSystemRoot + "\minidump")

CATE-Delete-Folder-Contents ($envSystemRoot + "\Downloaded Program Files")

CATE-Delete-Folder-Contents ($envSystemRoot + "\LiveKernelReports")

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

# Compact the Windows Search database, if found

$wsdb = "$env:AllUsersProfile" + "\Microsoft\Search\Data\Applications\Windows\Windows.edb"
if (Test-Path -Path $wsdb -PathType Leaf) {
	Write-Output "Compacting the Windows Search database..."

	Write-Output "Stopping service..."
	Stop-Service wsearch -ErrorAction SilentlyContinue *> $null
	Write-Output "Compacting..."
	& esentutl.exe /d $wsdb
	Write-Output "Setting service for delayed start..."
	start-process -FilePath sc.exe -ArgumentList 'config wsearch start=delayed-auto' -ErrorAction SilentlyContinue *> $null
	Write-Output "Restarting service..."
	Start-Service wsearch -ErrorAction SilentlyContinue *> $null
}

Write-Output "Compacting the Windows Update database..."

Write-Output "Stopping services..."
Stop-Service wuauserv *> $null
Stop-Service bits *> $null
Write-Output "Compacting..."
& esentutl.exe /d ("$env:WINDIR" + '\SoftwareDistribution\DataStore\DataStore.edb')
Write-Output "Restarting services..."
Start-Service wuauserv *> $null
Start-Service bits *> $null


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
































# SIG # Begin signature block
# MIIQIQYJKoZIhvcNAQcCoIIQEjCCEA4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/Nr/RnjOdi2uudzAeAjYr1bg
# 1VqgggupMIIDDDCCAfSgAwIBAgIQGsDSayfiep9MU0Gn9qSESTANBgkqhkiG9w0B
# AQsFADAeMRwwGgYDVQQDDBNDQlQgUG93ZXJTaGVsbCBDb2RlMB4XDTIwMDgyNjE0
# Mjc1MloXDTI1MDgyNjE0Mzc1MlowHjEcMBoGA1UEAwwTQ0JUIFBvd2VyU2hlbGwg
# Q29kZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN2yXYLb9UAxirdD
# q1wGZNWYCUGXlju/a3aZmN8iVpJRAxr1IsJmeEjgZgvhKxCFiQOulI1XzfC0qF3E
# W5wSZbmoXlHkeihS3Qne4735WEAAp0JVVsdstZuK3faFJCtaWorhtHF9QTfPmMZb
# CU40CNmZmaH/FaAvwX7Y0lt2bNLbf6ICgwwMQy1KOQIQtgIZYohBM9ceC+OyU/ko
# VVvMFQeX9V+vYijAWJxlpTv+A52Z4MvlkpO+zdVKBm3pg0BVxK/jgk288K9otTCY
# AybawIjeVS77C//wGwQjM+Qgpdswhxnu9AYUtREht9aaqL2trA3eIQhdzFCMpTze
# L3KEFqECAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBTuCNhmsoGL4xfXdeHB9ajub1TGKjANBgkqhkiG9w0BAQsF
# AAOCAQEATsu+0CzTZUEniNgB+6gJ5Ver2WexHfVumGqXQ/VgSV6o7Na1adM5YDEl
# OOupwxAqYyHRh7S6ljOTqSxs0MXv0u3N9WuL8QKTZi6N8b6Fm9721TZiszxDdefW
# ZxgSkRq9UAsx9yyVEq6JfKenH/JmPPZ/a7E0ioYTkAHNR3CHTh8WeeQBBWpFDO7X
# mtAjrSbNTymvE+zAQ8t6BuxAua5JzGrBGbEKaTMhwFP/nseeCMKRNsH6EevnYah/
# +DmW6AzXJOuoazW+KNF54T6drKTx1lLBFfTjNSCKwN6Z82jpFfCD1/XDWC8njt/N
# 766cq+efmqOajiWX6uQSIIPH3Oy9cDCCA+4wggNXoAMCAQICEH6T6/t8xk5Z6kua
# d9QG/DswDQYJKoZIhvcNAQEFBQAwgYsxCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxX
# ZXN0ZXJuIENhcGUxFDASBgNVBAcTC0R1cmJhbnZpbGxlMQ8wDQYDVQQKEwZUaGF3
# dGUxHTAbBgNVBAsTFFRoYXd0ZSBDZXJ0aWZpY2F0aW9uMR8wHQYDVQQDExZUaGF3
# dGUgVGltZXN0YW1waW5nIENBMB4XDTEyMTIyMTAwMDAwMFoXDTIwMTIzMDIzNTk1
# OVowXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9u
# MTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0g
# RzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCxrLNJVEuXHBIK2CV5
# kSJXKm/cuCbEQ3Nrwr8uUFr7FMJ2jkMBJUO0oeJF9Oi3e8N0zCLXtJQAAvdN7b+0
# t0Qka81fRTvRRM5DEnMXgotptCvLmR6schsmTXEfsTHd+1FhAlOmqvVJLAV4RaUv
# ic7nmef+jOJXPz3GktxK+Hsz5HkK+/B1iEGc/8UDUZmq12yfk2mHZSmDhcJgFMTI
# yTsU2sCB8B8NdN6SIqvK9/t0fCfm90obf6fDni2uiuqm5qonFn1h95hxEbziUKFL
# 5V365Q6nLJ+qZSDT2JboyHylTkhE/xniRAeSC9dohIBdanhkRc1gRn5UwRN8xXnx
# ycFxAgMBAAGjgfowgfcwHQYDVR0OBBYEFF+a9W5czMx0mtTdfe8/2+xMgC7dMDIG
# CCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AudGhhd3RlLmNv
# bTASBgNVHRMBAf8ECDAGAQH/AgEAMD8GA1UdHwQ4MDYwNKAyoDCGLmh0dHA6Ly9j
# cmwudGhhd3RlLmNvbS9UaGF3dGVUaW1lc3RhbXBpbmdDQS5jcmwwEwYDVR0lBAww
# CgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgEGMCgGA1UdEQQhMB+kHTAbMRkwFwYD
# VQQDExBUaW1lU3RhbXAtMjA0OC0xMA0GCSqGSIb3DQEBBQUAA4GBAAMJm495739Z
# MKrvaLX64wkdu0+CBl03X6ZSnxaN6hySCURu9W3rWHww6PlpjSNzCxJvR6muORH4
# KrGbsBrDjutZlgCtzgxNstAxpghcKnr84nodV0yoZRjpeUBiJZZux8c3aoMhCI5B
# 6t3ZVz8dd0mHKhYGXqY4aiISo1EZg362MIIEozCCA4ugAwIBAgIQDs/0OMj+vzVu
# BNhqmBsaUDANBgkqhkiG9w0BAQUFADBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMU
# U3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3Rh
# bXBpbmcgU2VydmljZXMgQ0EgLSBHMjAeFw0xMjEwMTgwMDAwMDBaFw0yMDEyMjky
# MzU5NTlaMGIxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjE0MDIGA1UEAxMrU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBT
# aWduZXIgLSBHNDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKJjCzlE
# uLsjp0RJuw7/ofBhClOTsJjbrSwPSsVu/4Y8U1UPFc4EPyv9qZaW2b5heQtbyUyG
# duXgQ0sile7CK0PBn9hotI5AT+6FOLkRxSPyZFjwFTJvTlehroikAtcqHs1L4d1j
# 1ReJMluwXplaqJ0oUA4X7pbbYTtFUR3PElYLkkf8q672Zj1HrHBy55LnX80QucSD
# ZJQZvSWA4ejSIqXQugJ6oXeTW2XD7hd0vEGGKtwITIySjJEtnndEH2jWqHR32w5b
# MotWizO92WPISZ06xcXqMwvS8aMb9Iu+2bNXizveBKd6IrIkri7HcMW+ToMmCPsL
# valPmQjhEChyqs0CAwEAAaOCAVcwggFTMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
# BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeAMHMGCCsGAQUFBwEBBGcwZTAq
# BggrBgEFBQcwAYYeaHR0cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDcGCCsG
# AQUFBzAChitodHRwOi8vdHMtYWlhLndzLnN5bWFudGVjLmNvbS90c3MtY2EtZzIu
# Y2VyMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly90cy1jcmwud3Muc3ltYW50ZWMu
# Y29tL3Rzcy1jYS1nMi5jcmwwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVT
# dGFtcC0yMDQ4LTIwHQYDVR0OBBYEFEbGaaMOShQe1UzaUmMXP142vA3mMB8GA1Ud
# IwQYMBaAFF+a9W5czMx0mtTdfe8/2+xMgC7dMA0GCSqGSIb3DQEBBQUAA4IBAQB4
# O7SRKgBM8I9iMDd4o4QnB28Yst4l3KDUlAOqhk4ln5pAAxzdzuN5yyFoBtq2MrRt
# v/QsJmMz5ElkbQ3mw2cO9wWkNWx8iRbG6bLfsundIMZxD82VdNy2XN69Nx9DeOZ4
# tc0oBCCjqvFLxIgpkQ6A0RH83Vx2bk9eDkVGQW4NsOo4mrE62glxEPwcebSAe6xp
# 9P2ctgwWK/F/Wwk9m1viFsoTgW0ALjgNqCmPLOGy9FqpAa8VnCwvSRvbIrvD/niU
# UcOGsYKIXfA9tFGheTMrLnu53CAJE3Hrahlbz+ilMFcsiUk/uc9/yb8+ImhjU5q9
# aXSsxR08f5Lgw7wc2AR1MYID4jCCA94CAQEwMjAeMRwwGgYDVQQDDBNDQlQgUG93
# ZXJTaGVsbCBDb2RlAhAawNJrJ+J6n0xTQaf2pIRJMAkGBSsOAwIaBQCgeDAYBgor
# BgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEE
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQX
# IWDd1KdzBqy8KN4/YBjHRZfVvDANBgkqhkiG9w0BAQEFAASCAQDBTdblTRtef6sp
# W3EZJ1DJ1QeWHz7tgowD1UnpCNvMRYz8V7pXb9vpw3WbuvcWrEqHCO6ceUc2ox5X
# nz7o5mMcsnYQDFqHZuythTrpXQGFX4xNsQNB6bdzJT5M1AIjQfa7BL+l/qGTA622
# bU0VgWFdL0EW4KxZlpHNAJfj+aaWji9Yxpo8p3MXf78rFGjnoU6Fl6KeuB6p0aT+
# W8EBiZVejTXSI48Pxkp3sKr1JwVtoOX1JemugXcw0Q3Oln+HdixTeNvSEUPNjCBA
# C/JKJr+MdfbrBc9XjgqRt01c9xbY85aDa4p+QxgEHHkDk05wB9S8Oe0Z8tZnC81j
# cvku8tYBoYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81
# bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
# HAYJKoZIhvcNAQkFMQ8XDTIwMDgyNjE0Mzc1NlowIwYJKoZIhvcNAQkEMRYEFGU/
# BmgE+/c9F4OjC17wHXBftwNkMA0GCSqGSIb3DQEBAQUABIIBAFxqLIv4/gOd7gDc
# lXtQhIWd+TmhaL98K0grCkv5e+RFKHZmUgX5XNL5koI4EQVbKBvZ8Bhx+Go2CT59
# KTy6GvekCL8I2uQfdyBpiTIPbqWf0uPa5Ss0Bt+g5g9jFU1Rgeebah/PiMkSYe8N
# KQ6ouhQ/sNOBratWZ6Tb7nEMKAcZLsaKpdIMPJLp3UEI9YiTUGHeS8hi+HxFWRLK
# ifPdlThhj9J33OxwPs2Q/+VXzzS1v9l0EsKoPVCibYme+6eLM0MBWfEh2u7mpfoe
# HD0szdVsMg8nYN6VWIRZ29+JRm/nqRmkWf1yj2nS8f9mP2e70GIB4RmnYD+PNOrb
# iPdfVTk=
# SIG # End signature block
