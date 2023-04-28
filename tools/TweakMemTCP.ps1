
<#PSScriptInfo

.VERSION 1.2

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
Tweaks memory and TCP parameters, for performance.

#>

Param()


################################################
# TweakMemTCP: Tweak Memory and TCP Parameters #
################################################

#
# by Jonathan E. Brickman
#
# Tweaks memory and TCP parameters, for performance.
#
# Copyright 2020 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
""
"**************************************************"
"   TweakMemTCP: Tweak Memory and TCP Parameters   "
"**************************************************"
""
""

# Self-elevate if not already elevated.
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
    "Running elevated; good."
    ""
    } else {
    "Not running as elevated.  Starting elevated shell."
    Start-Process powershell -WorkingDirectory $PWD.Path -Verb runAs -ArgumentList "-noprofile -noexit -file $PSCommandPath"
    return "Done. This one will now exit."
    ""
    }


""

# Now we make changes.
# http://www.tomsitpro.com/articles/powershell_registry-powershell_command_line,2-152.html

# The settings come from a quite reliable source:
# https://support.storagecraft.com/s/article/Tuning-Guide-for-StorageCraft-Software-on-Servers?language=en_US

$WinVersionStr = Get-CimInstance -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption

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
		Finally {
			$oldValue = ""
			}
        }

    #############
    # If an existing registry entry exists, store its value to report later
    Try {
        $oldValueProperty = Get-ItemProperty -Path $regPath -Name $nameForDWORD -ErrorAction SilentlyContinue
        $oldValue = $oldValueProperty.$nameforDWORD
        }
	Catch {}

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

if ( 		($WinVersionStr -Like "*Windows Server 2008 R2*") 	`
		-Or ($WinVersionStr -Like "*Windows 7*") 				`
		-Or ($WinVersionStr -Like "*Windows 8*")				`
		-Or ($WinVersionStr -Like "*Windows 10*")				`
		-Or ($WinVersionStr -Like "*Windows 201*") ) 
	{
	Write-Output "Windows 7/2008R2 or later found.  Setting appropriately."
	Write-Output ""
	
	# Original set
	
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" 	0x1
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SystemPages" 		0x0
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "PagedPoolSize" 		0x0b71b000
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "PoolUsageMaximum" 	0x00000050
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SessionPoolSize" 	0x00000030
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SessionViewSize" 	0x00000044
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "IRPStackSize" 0x00000020
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "Size" 		0x00000003
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpTimedWaitDelay" 		0x0000001e
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "StrictTimeWaitSeqCheck" 	0x00000001
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 			0x00007fff
	
	# Newer set, TCP only
	
	Set-NetOffloadGlobalSetting -Chimney Disabled | Out-Null
	netsh int tcp set global rss=disabled | Out-Null
	netsh int ip set global taskoffload=disabled | Out-Null
	netsh int tcp set global autotuninglevel=disabled | Out-Null
	netsh int tcp set supplemental custom congestionprovider=none | Out-Null
	netsh int tcp set global ecncapability=disabled | Out-Null
	netsh int tcp set global timestamps=disabled | Out-Null
	netsh int tcp set supplemental custom congestionprovider = ctcp | Out-Null
	netsh int tcp set global ecncapability=enabled | Out-Null
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableTCPA" 0x1
	}
else {
	Write-Output "Pre-Windows-7 found.  Setting appropriately."
	Write-Output ""
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "PagedPoolSize" 		0xffffffff
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "PoolUsageMaximum" 	0x0000003c
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SessionPoolSize" 	0x00000030
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SessionViewSize" 	0x00000044
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "IrpStackSize" 0x00000018
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "Size" 		0x00000003
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpTimedWaitDelay" 		0x0000001e
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "StrictTimeWaitSeqCheck" 	0x00000001
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 			0x00007fff
	}
	
# For StorageCraft ImageManager, if it exists
# https://support.storagecraft.com/articles/en_US/Informational/Tuning-Guide-for-StorageCraft-Software-on-Servers
If ( (Test-Path "C:\Program Files (x86)\StorageCraft\ImageManager") -Or (Test-Path "C:\Program Files\StorageCraft\ImageManager") )
	{
	Write-Output "StorageCraft ImageManager found."
	Write-Output ""
	setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\StorageCraft ImageManager\Parameters" "ReadUnbuffered" 0x1
	}
	
# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called
# the "New BSD License" or "Modified BSD License".
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
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
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








