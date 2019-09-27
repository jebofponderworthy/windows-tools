#######################################################################
# Windows 10 Performance                                              #
#######################################################################

#
# by Jonathan E. Brickman
#
# Speeds up Windows 10.  Specifically:
#
# 1. Removes several AppX packages which Microsoft has preloaded, whose
# contents often pop up without warning, eating resources.
#
# 2. Turns off preloading of the Edge browser.
# 
# 3. Turns off Game Mode.
#
# The latter two changes identified by the extraordinary Joe Busby.
#
# Copyright 2019 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#
#

Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxIdentityProvider"  | Remove-AppxPackage
Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay"  | Remove-AppxPackage 
Get-AppxPackage "Microsoft.WindowsCommunicationsApps" | Remove-AppxPackage
Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage 
Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage 
Get-AppxPackage "Microsoft.Advertising.Xaml" | Remove-AppxPackage

Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage -allusers
Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage -allusers
Get-AppxPackage "Microsoft.XboxIdentityProvider"  | Remove-AppxPackage -allusers
Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage -allusers
Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay"  | Remove-AppxPackage  -allusers
Get-AppxPackage "Microsoft.WindowsCommunicationsApps" | Remove-AppxPackage -allusers
Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage  -allusers
Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage -allusers
Get-AppxPackage "Microsoft.Advertising.Xaml" | Remove-AppxPackage -allusers

CD HKCU:\Software\Policies\Microsoft\
mkdir MicrosoftEdge
mkdir MicrosoftEdge\Main
CD MicrosoftEdge\Main
New-ItemProperty . -Name AllowPrelaunch -Value 0 -PropertyType "DWord" -Force

CD HKLM:\Software\Policies\Microsoft\
mkdir MicrosoftEdge
mkdir MicrosoftEdge\Main
CD MicrosoftEdge\Main
New-ItemProperty . -Name AllowPrelaunch -Value 0 -PropertyType "DWord" -Force

CD HKCU:\Software\Microsoft\
mkdir GameBar
New-ItemProperty . -Name AllowAutoGameMode -Value 0 -PropertyType "DWord" -Force

CD HKLM:\Software\Microsoft\
mkdir GameBar
New-ItemProperty . -Name AllowAutoGameMode -Value 0 -PropertyType "DWord" -Force

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



