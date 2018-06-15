
<#PSScriptInfo

.VERSION 3.02

.GUID ced41cc3-0763-4229-be97-4aac877c39e2

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
OWTAS
This tool sets a number of additional critical and delayed worker threads,
plus service work items. The changes are autocalculated according to a
combination of RAM and OS bit-width (32 vs. 64). Performance will increase,
more so with more RAM.

Documentation on these settings has ranged from sparse to none over many years. 
The early Microsoft documents used in the calculations appear completely gone,
there are some new ones. The settings produced by OWTAS have undergone testing
over the last ten years, on a wide variety of Wintelamd platforms, and appear 
to work well on all.

.PRIVATEDATA 

#> 



<# 

.DESCRIPTION 
OWTAS - enhances performance by adding threads. Optimizes critical and delayed worker threads and service work items.

#> 

Param()


#################################
#           Optimize VSS        #
#################################

#
# by Jonathan E. Brickman
#
# Removes all orphan shadows, and then preallocates 20% 
# of each drive volume for VSS as many different tools' 
# docs advise.
#
# Copyright 2018 Jonathan E. Brickman
# https://notes.ponderworthy.com/ 
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
"Optimize VSS"
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

# Remove orphan shadows.

"Removing orphan shadows..."
""
$out = (iex -Command 'vssadmin delete shadows /all /quiet')
""

# Get list of VSS-related volumes, and run the appropriate command on each.
# This includes all volumes which are VSS-aware, whether or not they have
# drive letters.

$VSSVolumesData = (vssadmin list volumes)
ForEach ($DataLine in $VSSVolumesData) {
    If ((-join $DataLine[0..12]) -eq "Volume path: ") {
        $VolumeID = (-join $DataLine[13..60])
        "Setting VSS preallocation to 20% for: " + $VolumeID
        ""
        If (((Get-WmiObject Win32_OperatingSystem).Caption) -match "Server") {
            $out = (iex -Command ('vssadmin add shadowstorage /For="' + $VolumeID + '" /On="' + $VolumeID + '" /MaxSize=20%'))
            $out = (iex -Command ('vssadmin resize shadowstorage /For="' + $VolumeID + '" /On="' + $VolumeID + '" /MaxSize=20%'))
            }
        Else {
            $out = (iex -Command ('vssadmin resize shadowstorage /For="' + $VolumeID + '" /On="' + $VolumeID + '" /MaxSize=20%'))
            }
        ""
        }
    }





