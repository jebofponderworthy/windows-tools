
<#PSScriptInfo

.VERSION 3.2

.GUID 527423ef-dadd-45b1-a547-56d2fdb325d1

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2018 Jonathan E. Brickman

.TAGS 

.LICENSEURI https://opensource.org/licenses/BSD-3-Clause

.PROJECTURI https://github.com/jebofponderworthy/windows-tools

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
TweakNTFS
Tweaks all NTFS volumes on a system for
performance and reliability, using FSUTIL

.PRIVATEDATA 

#> 













































<#

.DESCRIPTION 
TweakNTFS - optimizes NTFS volumes for performance and reliability

#>

Param()


#####################################
# TweakNTFS: Tweak All NTFS Volumes #
#  for Performance And Reliability  #
#####################################

#
# by Jonathan E. Brickman
#
# Tweaks all NTFS volumes on a system for
# performance and reliability, using FSUTIL
#
# Copyright 2018 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
""
"***************"
"   TweakNTFS   "
"***************"

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


"Tweaks for all drives..."
Invoke-Expression ('fsutil 8dot3name set 1') -ErrorAction SilentlyContinue
Invoke-Expression ('fsutil behavior set DisableLastAccess 1') -ErrorAction SilentlyContinue
Invoke-Expression ('fsutil behavior set DisableDeleteNotify 0') -ErrorAction SilentlyContinue # Turn SSD TRIM on if SSD is present

function Unzip {
	param([string]$zipfile, [string]$outpath)

	[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath) > $null
	}

function Install-Contig {
    
	$StartupDir = $pwd

	# First, set up temporary space and move there.

	"Setting up to download Contig..."

	$TempFolderName = -join ((65..90) + (97..122) | Get-Random -Count 10 | ForEach-Object {[char]$_})

	$envTEMP = [Environment]::GetEnvironmentVariable("TEMP")
	$TempPath = "$envTEMP\$TempFolderName"
	mkdir $TempPath > $null

	# Then download the zip file.

	"Downloading the Contig zip file from Microsoft..."

	Remove-Item "$TempPath\Contig.zip" -ErrorAction SilentlyContinue | Out-Null
	$WebClientObj = (New-Object System.Net.WebClient)
	$WebClientObj.DownloadFile("https://download.sysinternals.com/files/Contig.zip","$TempPath\Contig.zip") | Out-Null

	# Now unpack the zip file.

	"Unpacking..."

	Add-Type -AssemblyName System.IO.Compression.FileSystem

	$envWINDIR = [Environment]::GetEnvironmentVariable("WINDIR")
	Remove-Item "$envWINDIR\Contig.exe" -ErrorAction SilentlyContinue | Out-Null
	Remove-Item "$envWINDIR\Contig64.exe" -ErrorAction SilentlyContinue | Out-Null
	Remove-Item "$envWINDIR\Eula.txt" -ErrorAction SilentlyContinue | Out-Null
	Unzip "$TempPath\Contig.zip" "$envWINDIR" -Force

    }
	
function Defrag-NTFS-Metafiles {
	param([string]$DriveID)

	""
	"Defragmenting NTFS metafiles for " + $DriveID + " ..."
	""
	
	if ([System.IntPtr]::Size -eq 4) {
		# 32-bit OS
		$cmdstr = "CONTIG"
		} else {
		$cmdstr = "CONTIG64"
		}

	'$Mft ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Mft') -ErrorAction SilentlyContinue | Out-Null
	'$LogFile ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$LogFile') -ErrorAction SilentlyContinue | Out-Null
	'$Volume ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Volume') -ErrorAction SilentlyContinue | Out-Null
	'$AttrDef ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$AttrDef') -ErrorAction SilentlyContinue | Out-Null
	'$Bitmap ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Bitmap') -ErrorAction SilentlyContinue | Out-Null
	'$Boot ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Boot') -ErrorAction SilentlyContinue | Out-Null
	'$BadClus ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$BadClus') -ErrorAction SilentlyContinue | Out-Null
	'$Secure ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Secure') -ErrorAction SilentlyContinue | Out-Null
	'$Upcase ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Upcase') -ErrorAction SilentlyContinue | Out-Null
	'$Extend ...'
	Invoke-Expression ($cmdstr + ' -nobanner -accepteula ' + $DriveID + '$Extend') -ErrorAction SilentlyContinue | Out-Null

	}
	
"Get Contig to defragment NTFS metafiles..."

Install-Contig

Get-CimInstance -Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" | ForEach-Object {
    $DriveID = $_.DeviceID

    If ($DriveID -match "[A-Z]")
        {
        "Tweaking " + $DriveID + " ..."
		""
		
		"fsutil repair ..."
		Invoke-Expression ('fsutil repair set ' + $DriveID + ' 0x01') -ErrorAction SilentlyContinue | Out-Null
		"fsutil resource setautoreset true ..."
		Invoke-Expression ('fsutil resource setautoreset true ' + ($DriveID + '\')) -ErrorAction SilentlyContinue | Out-Null
		"fsutil resource setconsistent ..."
		Invoke-Expression ('fsutil resource setconsistent ' + ($DriveID + '\')) -ErrorAction SilentlyContinue | Out-Null
		"fsutil resource setlog shrink 10 ..."
		Invoke-Expression ('fsutil resource setlog shrink 10 ' + ($DriveID + '\')) -ErrorAction SilentlyContinue | Out-Null
		""
		Defrag-NTFS-Metafiles($DriveID)
		""
        }
    }

"Done!"

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















