
<#PSScriptInfo

.VERSION 3.8

.GUID ced41cc3-0763-4229-be97-4aac877c39e2

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
OVSS
Removes all orphan shadows, and then preallocates 20%
of each drive volume for VSS, as docs for different tools
advise.

.PRIVATEDATA

#> 



















































<#

.DESCRIPTION 
OVSS - optimizes VSS preallocation to 40% for each NTFS volume, and clears orphan shadows

#>

Param()


#################################
#           Optimize VSS        #
#################################

#
# by Jonathan E. Brickman
#
# Removes all orphan shadows, and then preallocates 40%
# of each drive volume for VSS as many different tools'
# docs advise.  
#
# Not using 
#   vssadmin delete shadows /all
# anymore, because security tools are flagging this as
# a violation.
#
# Copyright 2020 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
""
"******************"
"   Optimize VSS   "
"******************"
""
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

# Get list of VSS-related volumes, and run the appropriate command on each.
# This includes all volumes which are VSS-aware, whether or not they have
# drive letters.

$VSSVolumesData = (vssadmin list volumes)
ForEach ($DataLine in $VSSVolumesData) {
    If ((-join $DataLine[0..12]) -eq "Volume path: ") {
        $VolumeID = (-join $DataLine[13..60])
        "Setting for: " + $VolumeID
        ""
		
		$ForString = "/For=$VolumeID"
		$OnString = "/On=$VolumeID"
        If (((Get-CimInstance Win32_OperatingSystem).Caption) -match "Server") {
			# If a server, add the preallocation if it doesn't already exist, set to 1% max size
            & vssadmin add shadowstorage $ForString $OnString /MaxSize=1% | Out-Null
			# If exists, set to 1%, to delete old shadows
            & vssadmin resize shadowstorage $ForString $OnString /MaxSize=1% | Out-Null
			# Then set to 40%, a recommended standard
			& vssadmin resize shadowstorage $ForString $OnString /MaxSize=40% | Out-Null
            }
        Else {
			# Set to 1%, then 40%, to delete old shadows
			& vssadmin resize shadowstorage $ForString $OnString /MaxSize=1% | Out-Null
            & vssadmin resize shadowstorage $ForString $OnString /MaxSize=40% | Out-Null
            }
        ""
        }
    }


