
<#PSScriptInfo

.VERSION 3.53

.GUID f842f577-3f42-4cb0-91e7-97b499260a21

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2018 Jonathan E. Brickman

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


.PRIVATEDATA 

#> 















<# 

.DESCRIPTION 
Clean All Temp Etc - cleans temporary files and folders from all user profiles, clears logs, and more

#> 

Param()


#############################
# CATE: Clean All Temp Etc. #
#############################

#
# version 3.51
#
# by Jonathan E. Brickman
#
# Cleans temp files from all user profiles and
# several other locations.  Also clears log files.
#
# Copyright 2017 Jonathan E. Brickman
# https://notes.ponderworthy.com/ 
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
"Clean All Temp Etc."
""
"Cleans all profiles' temp and IE cache folders,"
"some other caches, and log files."
"Also removes Ask Partner Network items."
""

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

# Get initial shell location.

$InitialLocation = Get-Location

# Get environment variables.

$envTEMP = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$envTMP = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$envSystemDrive = $env:SystemDrive
$envSystemRoot = $env:SystemRoot
$envProgramData = $env:ProgramData

# Get initial free disk space.

function DriveSpace {
	param( [string] $strComputer) 

	# Does the server responds to a ping (otherwise the WMI queries will fail)

	$query = "select * from win32_pingstatus where address = '$strComputer'"
	$result = Get-WmiObject -query $query
	if ($result.protocoladdress) {

		$totalFreeSpace = 0

		# Get the Disks for this computer
		$colDisks = get-wmiobject Win32_LogicalDisk -computername $strComputer -Filter "DriveType = 3"

		# For each disk calculate the free space
		foreach ($disk in $colDisks) {
			$totalFreeSpace = $totalFreeSpace + $disk.freespace
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

# Here is an external variable to contain the "Status" text
# for progress reporting.

$reportStatus = "Working..."

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
    "\AppData\Local\Mozilla\Firefox\Profiles\*\cache",
    "\AppData\Local\Mozilla\Firefox\Profiles\*\cache2\entries",
    "\AppData\Local\Mozilla\Firefox\Profiles\*\thumbnails",
    "\AppData\Local\Mozilla\Firefox\Profiles\*\cookies.sqlite",
    "\AppData\Local\Mozilla\Firefox\Profiles\*\webappsstore.sqlite",
    "\AppData\Local\Mozilla\Firefox\Profiles\*\chromeappsstore.sqlite",
    "\AppData\Local\AskPartnerNetwork",
    "\Application Data\Local\Microsoft\Windows\WER",
    "\Application Data\Adobe\Flash Player\AssetCache",
    "\Application Data\Sun\Java\Deployment\cache",
    "\Application Data\Microsoft\CryptnetUrlCache"
    )

# A quasiprimitive for PowerShell-style progress reporting.

function ShowCATEProgress {
	param( [string]$currentOp )

    Write-Progress -Activity "Clean All Temp Etc" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }

# Here's a special routine for deletes, with
# our special sauce for reporting.

function DeleteFolderContents {
	param( [string]$strFolder,
           [bool]$skipSpecial = $false )

    ShowCATEProgress ""

    # If $strFolder is not a real folder, end function
    if ( !(Test-Path $strFolder) ) {
        return
        }

    # Try to CD/CHDIR/Set-Location into the folder.  
    # If cannot, return false for error.
    # This covers nonfolders.
    Try {
        Set-Location $strFolder
        }
    Catch {
        return
        }

    # Enumerate all contents and delete.  
    # For some reason, try/catch did not flag permissions errors when tested.
    Get-ChildItem -path $strFolder -Force -ErrorAction SilentlyContinue | ForEach {
        ShowCATEProgress $_
        If ( $_.PSIsContainer ) {
            # Item is a folder. 
            If ($skipSpecial) {
                # If $skipSpecial, attempt to remove it and everything under
                # except folders named "Low", "1", and "2".
                Try { Remove-Item $_ -Force -Recurse -Exclude "Low","1","2" -ErrorAction SilentlyContinue }
                Catch {}
                }
            else {
                # Attempt to remove it and everything under.
                Try { Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue }
                Catch {}
                }
            } 
        else {
                # Item is not a folder.
                Try { Remove-Item $_ -Force -ErrorAction SilentlyContinue }
                Catch {}
            }
        }
    }

# Next we loop through all of the paths for all user profiles 
# as recorded in the registry, and delete temp files.

# Outer loop enumerates all user profiles
$ProfileList = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"
$ProfileCount = $ProfileList.Count
$ProfileNumber = 1
$ProfileList | ForEach-Object {
    $profileItem = Get-ItemProperty $_.pspath
    $reportStatus = "Working on (profile " + $ProfileNumber + "/" + $ProfileCount + ") " + $profileItem.ProfileImagePath + " ..."
    $ProfileNumber += 1

    # Inner loop enumerates all folder subpaths within profiles to be cleaned
    ForEach ($folderSubpath in $foldersToClean) {
        $ToClean = $profileItem.ProfileImagePath+$folderSubpath
        If (Test-Path $ToClean) {
            # If the actual path exists, clean it
            ShowCATEProgress $ToClean
            DeleteFolderContents $ToClean
            }
        }

    # One special subpath needing TLC
    $ToClean = $profileItem.ProfileImagePath+"\AppData\Local\Temp"
    If (Test-Path $ToClean) {
        # If the actual path exists, clean it; the second parameter means skip folders named "Low", "1", or "2"
        ShowCATEProgress $ToClean
        DeleteFolderContents $ToClean $True
        }

    # Subpaths to be eliminated altogether, also present in the $foldersToClean list above
    Remove-Item "AskPartnerNetwork" -Force -Recurse -ErrorAction SilentlyContinue
    }

# Now empty certain folders

$reportStatus = "Working on other folders ..."

DeleteFolderContents ($envTEMP)

DeleteFolderContents ($envTMP)

DeleteFolderContents ($envSystemRoot + "\Temp"), $true

DeleteFolderContents ($envSystemRoot + "\system32\wbem\logs")

DeleteFolderContents ($envSystemRoot + "\system32\Debug")

DeleteFolderContents ($envSystemRoot + "\PCHEALTH\ERRORREP\UserDumps")

DeleteFolderContents ($envProgramData + "\Microsoft\Windows\WER\ReportQueue")

# Function to delete objects nonrecursively.  Can handle wildcards.

function DeleteObjects {
    param( [string]$strPath  )

    ShowCATEProgress $strPath
    If ( !(Test-Path $strPath -ErrorAction SilentlyContinue) ) { return }
    Remove-Item -Path $strPath -Force -ErrorAction SilentlyContinue
    }


DeleteObjects ($envSystemRoot + "\system32\Logfiles\*\*.log")

DeleteObjects ($envSystemRoot + "\system32\Logfiles\*\*.EVM")

DeleteObjects ($envSystemRoot + "\system32\Logfiles\*\*.EVM.*")

DeleteObjects ($envSystemRoot + "\system32\Logfiles\*\*.etl")

DeleteObjects ($envSystemRoot + "\Logs\*\*.log")

DeleteObjects ($envSystemRoot + "\Logs\*.etl")

DeleteObjects ($envSystemRoot + "\inf\*.log")

DeleteObjects ($envSystemRoot + "\Prefetch\*.pf")


$finalFreeSpace = DriveSpace("localhost")
$strOut = RptDriveSpace( $finalFreeSpace )
$strOut = "Final free space (all drives):   " + $strOut + " megabytes."
Write-Output $strOut

$freedSpace = $finalFreeSpace - $initialFreeSpace
$strOut = RptDriveSpace ( $freedSpace )
$strOut = "Freed " + $strOut + " megabytes."
Write-Output ""
Write-Output $strOut
Write-Output ""

Start-Sleep 3

# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called 
# the AYA>A>??sA??.??oNew BSD LicenseAYA>A>??sA??,A? or AYA>A>??sA??.??oModified BSD LicenseAYA>A>??sA??,A?. 
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






