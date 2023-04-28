#######################################################################
# Reset Windows Update                                                #
# v1.0                                                                #
#######################################################################

#
# by Jonathan E. Brickman
#
# Resets Windows Update and Windows Update Agent, in 10.
#
#

""
""
"**************************"
"   Reset Windows Update   "
"**************************"
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

# Sets TLS version.  Necessary for some platforms.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

    Write-Progress -Activity "Reset Windows Update" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }

Function PrepareModule {
	param( [string]$ModuleName )

	If (Get-Module -ListAvailable -Name $ModuleName)
		{ Update-Module $ModuleName }
	Else
		{ Install-Module $ModuleName }
	}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force > $null

ShowProgress("Preparing Powershell environment...","Setting up to use Powershell Gallery...")

ShowProgress("Preparing Powershell environment:","Setting up to use page provider NuGet...")
Install-PackageProvider -Name NuGet -Force | Out-Null

# This appears to set PSGallery nicely when need be
Register-PSRepository -Default -InstallationPolicy Trusted 2> $null
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

ShowProgress("Preparing Powershell environment...","Checking/preparing module NuGet...")
PrepareModule("NuGet")
ShowProgress("Preparing Powershell environment...","Checking/preparing module PSWindowsUpdate...")
PrepareModule("PSWindowsUpdate")

Reset-WUComponents

ShowProgress("Done!","")

# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called
# the AYA>A>??sA??.??oNew BSD LicenseAYA>A>??sA??,A? or AYA>A>??sA??.??oModified BSD LicenseAYA>A>??sA??,A?.
# See also the 2-clause BSD License.

# Copyright 2018 Jonathan E. Brickman

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

