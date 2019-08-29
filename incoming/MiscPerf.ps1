
<#PSScriptInfo

.VERSION 1.01

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
OtherPerf
Other performance tweaks for windows-tools:
increase dynamic IP ports available, and
turn off Microsoft Compatibility Telemetry.

.PRIVATEDATA 

#> 













































<#

.DESCRIPTION 
OtherPerf - increase dynamic IP ports available, and turn off Microsoft Compatibility Telemetry.

#>

Param()


######################################
# OtherPerf: Other Performance Items #
######################################

#
# by Jonathan E. Brickman
#
# Increase dynamic IP ports available, and turn off Microsoft Compatibility Telemetry.
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
"   OtherPerf   "
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

"Increase dynamic IP ports available in Windows..."
Invoke-Expression ('netsh int ipv4 set dynamicport tcp start=1025 num=64511') -ErrorAction SilentlyContinue | Out-Null

"Two registry entries to go with..."

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
if (!(Test-Path $registryPath)) {
	New-Item -Path $registryPath -Force | Out-Null
	}
New-ItemProperty -Path $registryPath -Name "TcpTimedWaitDelay" -Value "00000030" -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "StrictTimeWaitSeqCheck" -Value "00000001" -PropertyType DWORD -Force | Out-Null

"And one registry entry to disable Microsoft Compatibility Telemetry..."

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $registryPath)) {
	New-Item -Path $registryPath -Force | Out-Null
	}
New-ItemProperty -Path $registryPath -Name "Allow Telemetry" -Value "0" -PropertyType DWORD -Force | Out-Null

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
















