
<#PSScriptInfo

.VERSION 2.14

.GUID 527423ef-dadd-45b1-a547-56d2fdb325d1

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
"TweakNTFS"
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


"Tweaks for all drives..."
Invoke-Expression ('fsutil 8dot3name set 1') -ErrorAction SilentlyContinue
Invoke-Expression ('fsutil behavior set disablelastaccess 1') -ErrorAction SilentlyContinue

Get-CimInstance -Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" | ForEach-Object {
    $DriveID = $_.DeviceID

    If ($DriveID -match "[A-Z]")
        {
        "Tweaking " + $DriveID + " ..."
		""
		"> fsutil repair ..."
		""
        Invoke-Expression ('fsutil repair set ' + $DriveID + ' 0x01') -ErrorAction SilentlyContinue
		""
		"> fsutil resource setautoreset true ..."
		""
        Invoke-Expression ('fsutil resource setautoreset true ' + ($DriveID + '\')) -ErrorAction SilentlyContinue
		""
		"> fsutil resource setconsistent ..."
		""
        Invoke-Expression ('fsutil resource setconsistent ' + ($DriveID + '\')) -ErrorAction SilentlyContinue
		""
		"> fsutil resource setlog shrink 10 ..."
		""
        Invoke-Expression ('fsutil resource setlog shrink 10 ' + ($DriveID + '\')) -ErrorAction SilentlyContinue
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




