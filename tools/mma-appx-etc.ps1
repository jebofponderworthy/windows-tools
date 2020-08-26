
<#PSScriptInfo

.VERSION 2.5

.GUID 5cc3176c-2e44-40d7-8ead-592e4e2e3665

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
mma-appx-etc - performance gains of several kinds new to Windows 8/10/201*
Configures MMAgent (including Superfetch, Memory Compression, etc.) for performance,
removes several consumer-grade appx items, disables preload of Edge Browser,
and disables Game Mode.

#> 













<# 

.DESCRIPTION 
mma-appx-etc - performance gains of several kinds new to Windows 8/10/201*

#> 

Param()


#######################################################################
# MMA, appx, and other 8+/2012+/10+/201* performance items            #
# v2.5                                                                #
#######################################################################

#
# by Jonathan E. Brickman
#
# Speeds up Windows 8+/2012+, with special attention to 10 and up.  Specifically:
#
# 1. Set MMAgent for performance.  This includes Superfetch, prefetching,
# memory compression, and page combining.  Far better to do these things,
# than to just turn Superfetch off.
#
# 2. Removes several AppX packages which Microsoft has preloaded, whose
# contents may pop up without warning, eating resources.  This includes
# the consumer-grade email/calendar/contacts apps, several Xbox gaming items,
# et cetera.
#
# 3. Turns off preloading of the Edge browser.
# 
# 4. Turns off Game Mode.
#
# The latter two changes identified by the extraordinary Joe Busby.
#
# Copyright 2019 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
""
"**************************************************************"
"   MMA, appx, and other 8+/2012+/10+/201* performance items   "
"**************************************************************"
""
""

$WinVersionStr = Get-CimInstance -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption

if ($WinVersionStr -Like "*Windows 7*")
{
	"Windows 7.  Exiting."
	""
	exit 0
}

# Using this to suppress much error output:
$ErrorActionPreference= 'silentlycontinue'

"Configuring and enabling aspects of MMAgent..."

Set-Service sysmain -StartupType Automatic | Out-Null
Start-Service sysmain | Out-Null

Set-MMAgent -MaxOperationAPIFiles 8192 | Out-Null

$MMAgentSetup = Get-MMAgent

If (-Not $MMAgentSetup.ApplicationLaunchPrefetching)
	{ Enable-MMAgent -ApplicationLaunchPrefetching | Out-Null }
If (-Not ($WinVersionStr -Like "*Windows Server 201*"))
	{
	If (-Not $MMAgentSetup.ApplicationPrelaunch)
		{ Enable-MMAgent -ApplicationPreLaunch | Out-Null }
	}	
If (-Not $MMAgentSetup.MemoryCompression)
	{ Enable-MMAgent -MemoryCompression | Out-Null }
If (-Not $MMAgentSetup.OperationAPI)
	{ Enable-MMAgent -OperationAPI | Out-Null }
If (-Not $MMAgentSetup.PageCombining)
	{ Enable-MMAgent -PageCombining | Out-Null }
	
"Removing appx's..."

# Will add deprovisioning:  Remove-AppxProvisionedPackage -Online -PackageName MyAppxPkg

"1/10..."
Get-AppxPackage "Microsoft.XboxApp" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"2/10..."
Get-AppxPackage "Microsoft.XboxGameOverlay" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"3/10..."
Get-AppxPackage "Microsoft.XboxIdentityProvider"  -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"4/10..."
Get-AppxPackage "Microsoft.Xbox.TCUI" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"5/10..."
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" -allusers | Remove-AppxPackage  -allusers  -ErrorAction SilentlyContinue | Out-Null
"6/10..."
Get-AppxPackage "Microsoft.WindowsCommunicationsApps" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"7/10..."
Get-AppxPackage "Microsoft.BingNews" -allusers | Remove-AppxPackage  -allusers  -ErrorAction SilentlyContinue | Out-Null
"8/10..."
Get-AppxPackage "Microsoft.BingWeather" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"9/10..."
Get-AppxPackage "Microsoft.Advertising.Xaml" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null
"10/10..."
Get-AppxPackage "*Microsoft.Skype*" -allusers | Remove-AppxPackage -allusers  -ErrorAction SilentlyContinue | Out-Null

# Reregisters the remaining Appx items, this can solve lots of problems

"Reregistering needed Appx items..."

Get-AppXPackage -AllUsers | Foreach {
	Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue | Out-Null
	}

# The rest do not apply to Windows 8 / Server 2012 platforms.
if ( ($WinVersionStr -Like "*Windows Server 2012*") -Or ($WinVersionStr -Like "*Windows 8*") )
	{ exit 0 }

"Disabling prelaunch/preload of Microsoft Edge browser..."

pushd HKCU:\Software\Policies\Microsoft\ | Out-Null
mkdir MicrosoftEdge -Force | Out-Null
mkdir MicrosoftEdge\Main -Force | Out-Null
CD MicrosoftEdge\Main | Out-Null
New-ItemProperty . -Name AllowPrelaunch -Value 0 -PropertyType "DWord" -Force | Out-Null

CD HKLM:\Software\Policies\Microsoft\ | Out-Null
mkdir MicrosoftEdge -Force | Out-Null
mkdir MicrosoftEdge\Main -Force | Out-Null
CD MicrosoftEdge\Main | Out-Null
New-ItemProperty . -Name AllowPrelaunch -Value 0 -PropertyType "DWord" -Force | Out-Null

"Disabling AutoGameMode..."

CD HKCU:\Software\Microsoft\ | Out-Null
mkdir GameBar -Force  -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty . -Name AllowAutoGameMode -Value 0 -PropertyType "DWord" -Force  -ErrorAction SilentlyContinue | Out-Null

CD HKLM:\Software\Microsoft\ | Out-Null
mkdir GameBar -Force  -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty . -Name AllowAutoGameMode -Value 0 -PropertyType "DWord" -Force  -ErrorAction SilentlyContinue | Out-Null

"Disable Windows Compatibility Telemetry..."
schtasks /Change /Disable /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
taskkill /f /im compattelrunner.exe 2>&1 | Out-Null

popd | Out-Null

""

# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called
# the AYA>A>??sA??.??oNew BSD LicenseAYA>A>??sA??,A? or AYA>A>??sA??.??oModified BSD LicenseAYA>A>??sA??,A?.
# See also the 2-clause BSD License.

# Copyright 2019 Jonathan E. Brickman

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













# SIG # Begin signature block
# MIIQIQYJKoZIhvcNAQcCoIIQEjCCEA4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsaXG6afp2GKOlT+C/PerjaUa
# uUOgggupMIIDDDCCAfSgAwIBAgIQGsDSayfiep9MU0Gn9qSESTANBgkqhkiG9w0B
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
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ3
# R43onGHaB0ed9EI2AVnqNFI7NTANBgkqhkiG9w0BAQEFAASCAQCgYkfSD9lfnf8G
# v/D+q3r/pE+jbg8Jhid/P7f2SFYDes5WfIV++A7GMwJssrHI59/ibsbI3mIFtRgX
# /eTJz0JEAtBO9f06M0j+xYL0jc1KGb7I/3JZg/U60bSyqQlfQIci7VvtO5iJLc3r
# OXJyXBVZ4pQEHkS/KQ7n0/Y5Xig4OqHlXs2o4G3RVTcNs4/J4v74tcYQe0CSSm97
# zXm8DzM6qzDuX9Vxd2VRBDc7UDZir+4O5fXcsi3mzJPHLfeudiayS8iPRFBxljED
# AmxrQdu9uzT5rZ78cLLVCergGbRpAobJuVeM4rWFNEaQzV8umYEIokQToL7RXGwf
# KW6DndY4oYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81
# bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
# HAYJKoZIhvcNAQkFMQ8XDTIwMDgyNjE0Mzc1N1owIwYJKoZIhvcNAQkEMRYEFEwW
# IU1wKs7+0zzpGRHfmiLGgV2LMA0GCSqGSIb3DQEBAQUABIIBAELeSvbyurAFMiOP
# Hl1DmfaoQc5cB782AbbbPkaH64DAMb+UtuFsJB2wjQd1kT+84/i4aOMZGKDB3es9
# P+k3zjTPz8mn5W/ku3+ipp588SrIgMkRgoRA1U5jhW+kOdyXUCijMTaDsvJyM6CC
# 1RcOv9zAzdwZ4oOlUJ4APwDSPMY0xEdQ75j8wI5fVsYeZxTV9d6UNj1E7jXGHxYD
# urjHfBUlf+SBW+D46/BN6xcu/Ah918osNDQcjgJ0P8R37wF1BYBAouk6yjPEWTbx
# C1nKAMjv3BvIUZ/GxmUjotn+85elXoMAkhFyyOLyTxdQZSfHEEn0kj36XSa3r934
# yLGdM2c=
# SIG # End signature block
