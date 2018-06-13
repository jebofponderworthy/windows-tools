
<#PSScriptInfo

.VERSION 2.1

.GUID ce84b622-e1f5-4327-a0d8-f51e8b30d65d

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
 TweakNTFS - optimizes NTFS volumes for performance and reliability 

#> 

Param()


#####################################
# TweakNTFS: Tweak All NTFS Volumes #
#  for Performance And Reliability  #
#                                   #
# v2.1                              #
#####################################


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
$output = iex ('fsutil 8dot3name set 1') -ErrorAction SilentlyContinue
$output = iex ('fsutil behavior set disablelastaccess 1') -ErrorAction SilentlyContinue

Get-WMIObject -Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" | ForEach {
    $DriveID = $_.DeviceID

    If ($DriveID -match "[A-Z]")
        {
        "Tweaking " + $DriveID + " ..."
        $output = iex ('fsutil repair set ' + $DriveID + ' 0x01') -ErrorAction SilentlyContinue
        $output = iex ('fsutil resource setautoreset true ' + ($DriveID + '\')) -ErrorAction SilentlyContinue
        $output = iex ('fsutil resource setconsistent ' + ($DriveID + '\')) -ErrorAction SilentlyContinue
        $output = iex ('fsutil resource setlog shrink 10 ' + ($DriveID + '\')) -ErrorAction SilentlyContinue
        }
    }

"Done!"





