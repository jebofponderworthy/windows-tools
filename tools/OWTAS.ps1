
<#PSScriptInfo

.VERSION 3.06

.GUID 14025447-cf92-41ee-b735-3d99c9e2c4d5

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


######################################################
# OWTS: Optimize Worker Threads and Service Requests #
######################################################

#
# by Jonathan E. Brickman
#
# Optimizes default and extra worker threads and
# service requests.
#
# Documentation on these settings has ranged from sparse to none over
# many years.  The early Microsoft documents used in the 
# calculations are completely gone.  The settings have undergone
# testing over the last ten years, on a wide variety of Wintelamd platforms,
# and appear to work well on all.
#
# Copyright 2018 Jonathan E. Brickman
# https://notes.ponderworthy.com/ 
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
"Optimize Worker Threads and Service Requests"
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


# First find out how much RAM is in this machine

$totalRAMinBytes = (Get-WmiObject -class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum
$totalRAMinGB = [double]$totalRAMinBytes / 1024.0 / 1024.0 / 1024.0

"Available RAM: " + [int]$totalRAMinGB + "G"

# Then find out whether this OS is 32-bit or 64-bit, and calculate changes.
# We add half as many threads on a 64-bit OS, because each thread could take
# twice as much RAM, though does not always.

if ([System.IntPtr]::Size -eq 4) 
    { 
    # 32-bit OS

    $AddCriticalWorkerThreads = [Int][Math]::Truncate($totalRAMinGB * 6)
    $AddDelayedWorkerThreads = [Int][Math]::Truncate($totalRAMinGB * 6)
    $DefaultWorkerThreads = 64

    "OS bit width: 32"
    }
else 
    {
    # 64-bit OS

    $AddCriticalWorkerThreads = [Int][Math]::Truncate($totalRAMinGB * 3)
    $AddDelayedWorkerThreads = [Int][Math]::Truncate($totalRAMinGB * 3)
    $DefaultWorkerThreads = 64

    "OS bit width: 64"
    }

""

# Now we make changes.
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
    # Set new registry entry, or error out
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

setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" "AdditionalCriticalWorkerThreads" $AddCriticalWorkerThreads

setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" "AdditionalDelayedWorkerThreads" $AddDelayedWorkerThreads

setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters" "DefaultNumberOfWorkerThreads" $DefaultWorkerThreads

setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters" "MaxWorkItems" 8192

setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters" "MaxMpxCt" 2048

setupDWORD "HKLM:\SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters" "MaxCmds" 2048

    
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






