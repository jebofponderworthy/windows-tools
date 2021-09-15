
<#PSScriptInfo

.VERSION 4.0

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
# Removes all orphan shadows if possible, and then preallocates 40%
# of each drive volume for VSS as many different tools'
# docs advise.  
#
# Not using 
#   vssadmin delete shadows /all
# anymore, because security tools are flagging this as
# a violation.
#
# As of 4.0, applying VSS tweaks:
#
# HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\VSS\Settings
# DWORD MaxShadowCopies
# Microsoft-reported default is 64.  Minimum 1, maximum 512.
# Factually observed default appears much larger than 64.
# Setting to 32.
#
# HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\VolSnap
# DWORD MinDiffAreaFileSize
# No known default exists.  Must not be larger than MaxSize as set
# by VSSADMIN.
# Would like to set to 15% of minimum drive size, given that MaxSize seems to default
# at either unlimited or 20% depending on reference taken.  But 
# this is a system-wide setting for all drives at once!
# Also has to be a multiple of 32, as in 32 megabytes.
# We're not seeing drives smaller than 100G at this writing, so will use
# 10% of that, which is 10G, 10000M, nearest multiple of 32 is 32*312=9984.
# Hopefully not a problem for small flash drives.
#
# The best references for this thus far appear to be:
# https://docs.microsoft.com/en-us/windows/win32/backup/registry-keys-for-backup-and-restore
# https://support.microsoft.com/kb/945058
# https://support.microsoft.com/en-us/topic/mindiffareafilesize-registry-value-limit-is-increased-from-3-gb-to-50-gb-in-windows-8-1-or-windows-server-2012-r2-fbc32c81-1a4e-787b-ca7f-892225cd07e9
#
# Copyright 2021 Jonathan E. Brickman
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
        "Setting MaxSize and clearing for: " + $VolumeID
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

"General VSS settings:"
""

# Currently using these as constants.  
# Default MaxShadowCopies is reported as 64, 
# default MinDiffAreaFileSize is extremely small.
#
# The thought is by adjusting these, VSS will fail less, 
# hopefully keeping a shorter queue with more prerequisite resources per 
# execution.

$NewMaxShadowCopies = 32
$NewMinDiffAreaFileSize = 3200

# http://www.tomsitpro.com/articles/powershell_registry-powershell_command_line,2-152.html

function setupDWORD {
    param( [string]$regPath, [string]$nameForDWORD, [long]$valueForDWORD )

    ##############
    # Error out if cannot touch the registry area at all
    If ( !(Test-Path $regPath) ) {
        Try {
            New-Item $regPath -Force -ErrorAction SilentlyContinue
            }
        Catch {
            Write-Error ("Could not visit or create registry path " + $regPath)
            Return
            }
        }

    #############
    # If an existing registry entry exists, store its value to report later
    Try {
        $oldValueProperty = Get-ItemProperty -Path $regPath -Name $nameForDWORD -ErrorAction SilentlyContinue
        $oldValue = $oldValueProperty.$nameforDWORD
        }
    Catch {
        $oldValue = ""
        }

    #############
    # Report the changes to make
    Write-Output ("DWORD to write: " + $nameForDWORD)
    Write-Output ("at registry path " + $regPath)
    If ($oldValue -ne "") {
        Write-Output ("Original value is " + $oldValue)
        }
    else {
        Write-Output "No original present."
        }
    Write-Output ("New value is " + $valueforDWORD)

    ############
    # Report no changes to make, set new registry entry, or error out
	If ($oldValue -eq $valueforDWORD) {
		Write-Output "No change to make."
		""
		Return
		}
    Try {
        New-ItemProperty -Path $regPath -Name $nameForDWORD -Value $valueForDWORD -PropertyType DWORD -Force -ErrorAction SilentlyContinue > $null
        }
    Catch {
        Write-Error "Failed!"
        ""
        Return
        }

    "Succeeded!"
    ""
    }

setupDWORD "HKLM:\System\CurrentControlSet\Services\VSS\Settings" "MaxShadowCopies" $NewMaxShadowCopies
setupDWORD "HKLM:\System\CurrentControlSet\Services\VolSnap" "MinDiffAreaFileSize" $NewMinDiffAreaFileSize

""

"Restarting VSS..."

Restart-Service -Force -Name "VSS"

""

"Complete!"
""

