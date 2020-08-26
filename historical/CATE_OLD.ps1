
<#PSScriptInfo

.VERSION 4.7

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

# Embedded C# code for actual deletes.
# Needed because, as is reported very very rarely, PowerShell deletes are buggy
# and in practice often don't work, sometimes without error messages.

$RecursiveDeleteSource = @"
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Management.Automation.Runspaces;
using System.Runtime.InteropServices;


namespace CATEcsharp
{
	public class runtime
	{
		public static void RecursiveDeleteContentsOf(DirectoryInfo baseDir, int ProfileNumber)
		{
			if (!baseDir.Exists)
				return;

			Parallel.ForEach(baseDir.EnumerateDirectories(), (dir) => 
				{
				RecursiveDelete(dir, ProfileNumber);
				});
			
			Parallel.ForEach(baseDir.EnumerateFiles(), (file) =>
			{
				try
				{
					file.IsReadOnly = false;
					file.Delete();
					nextProgressDot();
					nextProgressString(ProgressDot);
					ShowCATEProgress("Deleting in " + baseDir.FullName + " ... ", ProgressString, ProfileNumber);
				}
				catch
				{
				}
			});
		}
	
		public static void RecursiveDelete(DirectoryInfo baseDir, int ProfileNumber)
		{
			if (!baseDir.Exists)
				return;

			Parallel.ForEach(baseDir.EnumerateDirectories(), (dir) => 
				{
				RecursiveDelete(dir, ProfileNumber);
				});

			Parallel.ForEach(baseDir.EnumerateFiles(), (file) =>
			{
				try
				{
					file.IsReadOnly = false;
					file.Delete();
					nextProgressDot();
					nextProgressString(ProgressDot);
					ShowCATEProgress("Deleting in " + baseDir.FullName + " ... ", ProgressString, ProfileNumber);
				}
				catch
				{
				}
			});
	
			try
			{
				baseDir.Delete();
				nextProgressString("/");
				ShowCATEProgress("Deleting in " + baseDir.FullName + " ... ", ProgressString, ProfileNumber);
			}
			catch
			{
			}
		}
		
		public static void RecursiveDeleteFilesOnly(DirectoryInfo baseDir, string Wildcard, int ProfileNumber)
		{
			if (!baseDir.Exists)
				return;

			Parallel.ForEach(baseDir.EnumerateDirectories(), (dir) => 
			{
				RecursiveDeleteFilesOnly(dir, Wildcard, ProfileNumber);
			});

			Parallel.ForEach(baseDir.EnumerateFiles(Wildcard), (file) =>
			{
				try
				{
					file.IsReadOnly = false;
					file.Delete();
					nextProgressDot();
					nextProgressString(ProgressDot);
					ShowCATEProgress("Deleting in " + baseDir.FullName + " ... ", ProgressString, ProfileNumber);
				}
				catch
				{
				}
			});
		}
		
		// ProgressString will gradually look something like this:  .....//..././...//.///.
		// maximum 60 characters long, updated by deleting the first and adding to the end.
		
		public static string ProgressString;
	
		public static void nextProgressString(string ProgressChar)
		{
			ProgressString += ProgressChar;
			if (ProgressString.Length > 60)
				ProgressString = ProgressString.Remove(0,1);  // Remove the first character.
		}
		
		// ProgressDot alternates between . (period, 46) and ? (middle dot, 183), so animation stays
		// visible when it's just many files.
		
		public static string ProgressDot;
		public static int DotCount = 1;
		
		public static void nextProgressDot()
		{
		DotCount++;
		if (DotCount % 3 == 0)
			{
			ProgressDot = ((char)183).ToString();	// Middle dot
			DotCount = 1;
			}
		else
			ProgressDot = ((char)46).ToString();	// Period
		}
	
		private static void ShowCATEProgress(string reportStatus, string currentOp, int profileNumber)
		{
			string statusText;
		
			if (profileNumber != 0)
				statusText = "Working on profile #" + profileNumber.ToString() + ". " + reportStatus;
			else
				statusText = reportStatus;
		
			var RptCmd = @"Write-Progress -Activity ""Clean All Temp Etc""";
			RptCmd += @" -Status """ + statusText + @""" -PercentComplete -1";
			RptCmd += @" -CurrentOperation """ + currentOp + @"""";
			// Console.Write(RptCmd + "\r\n");
			var runspace = Runspace.DefaultRunspace;
			var pipeline = runspace.CreateNestedPipeline(RptCmd, false);
			pipeline.Invoke();
		}
	}
}
"@
# Add the c# code to the powershell type definitions
Add-Type -TypeDefinition $RecursiveDeleteSource -Language CSharp

# Example code for a delete, working:
# [CATEcsharp.runtime]::RecursiveDeleteContentsOf('C:\test', 0)

function CATE-Recursive-Delete {
	param( [string]$strFolderPath, [int]$ProfileNumber=0  )
	
	ShowCATEProgress $CATEStatus $strFolderPath
	try {
		[CATEcsharp.runtime]::RecursiveDelete($strFolderPath, $ProfileNumber)
		}
	catch {
		}
	}
	
function CATE-Recursive-Delete-Folder-Contents {
	param( [string]$strFolderPath, [int]$ProfileNumber=0  )
	
	ShowCATEProgress $CATEStatus $strFolderPath
	try {
		[CATEcsharp.runtime]::RecursiveDeleteContentsOf($strFolderPath, $ProfileNumber)
		}
	catch {
		}
	}
	
function CATE-Recursive-Delete-Files-Only {
    param( [string]$strFolderPath, [string]$WildCard, [int]$ProfileNumber=0  )

    ShowCATEProgress $CATEStatus $strFolderPath
	try {
		[CATEcsharp.runtime]::RecursiveDeleteFilesOnly($strFolderPath, $WildCard)
		}
	catch {
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
    $CATEStatus = "Working on (profile " + $ProfileNumber + "/" + $ProfileCount + ") " + $profileItem.ProfileImagePath + " ..."
    $ProfileNumber += 1

    # This loop enumerates all non-Firefox folder subpaths within profiles to be cleaned
    ForEach ($folderSubpath in $foldersToClean) {
        $ToClean = $profileItem.ProfileImagePath + $folderSubpath
        If (Test-Path $ToClean) {
            # If the actual path exists, clean it
            CATE-Recursive-Delete-Folder-Contents $ToClean $ProfileNumber
            }
        }
		
	# These loops handle Firefox and multiple FF profiles if they exist
	$ffProfilePath = $profileItem.ProfileImagePath + '\AppData\Local\Mozilla\Firefox\Profiles\'
	If (Test-Path $ffProfilePath) {
		Get-ChildItem -Path $ffProfilePath | ForEach-Object {
			$ffProfilePath = Get-ItemProperty $_.pspath
		
			ForEach ($subPath in $ffFoldersToClean) {
				$ToClean = "$ffProfilePath\$subPath"
				CATE-Recursive-Delete-Folder-Contents $ToClean $ProfileNumber
				}
			}
		}
	$ffProfilePath = $profileItem.ProfileImagePath + '\AppData\Roaming\Mozilla\Firefox\Profiles\'
	If (Test-Path $ffProfilePath) {
		Get-ChildItem -Path $ffProfilePath | ForEach-Object {
			$ffProfilePath = Get-ItemProperty $_.pspath
		
			ForEach ($subPath in $ffFoldersToClean) {
				$ToClean = "$ffProfilePath\$subPath"
				CATE-Recursive-Delete-Folder-Contents $ToClean $ProfileNumber
				}
			}
		}

    # A subpath to be eliminated altogether, also present in the $foldersToClean list above
    CATE-Recursive-Delete ($profileItem.ProfileImagePath + '\AppData\Local\AskPartnerNetwork') $ProfileNumber
    }

# Now empty certain folders

$CATEStatus = "Working on other folders ..."

CATE-Recursive-Delete-Folder-Contents $envTEMP

CATE-Recursive-Delete-Folder-Contents $envTMP

CATE-Recursive-Delete-Folder-Contents ($envSystemRoot + "\Temp")

CATE-Recursive-Delete-Folder-Contents ($envSystemRoot + "\system32\wbem\logs")

CATE-Recursive-Delete-Folder-Contents ($envSystemRoot + "\system32\Debug")

CATE-Recursive-Delete-Folder-Contents ($envSystemRoot + "\PCHEALTH\ERRORREP\UserDumps")

CATE-Recursive-Delete-Folder-Contents ($envProgramData + "\Microsoft\Windows\WER\ReportQueue")

# And then delete log files by wildcard, recursing through folders

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.log'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.EVM'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.EVM.*'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\system32\Logfiles') '*.etl'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\Logs') '*.log'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\Logs') '*.etl'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\inf') '*.log'

CATE-Recursive-Delete-Files-Only ($envSystemRoot + '\Prefetch') '*.pf'

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
$strOut = "Freed " + $strOut + " megabytes."
Write-Output ""
Write-Output $strOut
Write-Output ""

Set-Location $originalLocation

Start-Sleep 7

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































