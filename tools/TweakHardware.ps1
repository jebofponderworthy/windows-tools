
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
TweakHardware
This tool changes NIC settings for performance, and turns off USB power saving.

Documentation on these settings has ranged from sparse to none over many years.
The early Microsoft documents used in the calculations appear completely gone,
there are some new ones. The settings produced by OWTAS have undergone testing
over the last ten years, on a wide variety of Wintelamd platforms, and appear 
to work well on all.

.PRIVATEDATA

#> 

























<#

.DESCRIPTION 
TweakMemTCP - enhances performance by adding threads. Optimizes critical and delayed worker threads and service work items.

#>

Param()


################################################################
# Tweak Hardware: NIC performance and disable USB power saving #
################################################################

#
# by Jonathan E. Brickman
#
# Tweaks NIC(s) for performance, and disables power saving for all
# USB devices.
#
# Copyright 2020 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
""
"*****************************************************************************"
"   TweakHardware: Tweak NICs for performance, and disable USB power saving   "
"*****************************************************************************"
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


""

# Get-NetAdapterAdvancedProperty gets a full list, for all NICs on a given machine.
# The below combines settings across multiple NIC types, most settings will not apply
# to all NICs.

# To get a list of valid values for many given items, example:
# $ValidValues = (Get-NetAdapterAdvancedProperty -Name "NIC Name" -DisplayName "Energy-Efficient Ethernet").ValidDisplayValues

Get-NetAdapter | ForEach-Object {
	"Changing settings on NIC <" + $_.Name + "> if/as appropriate..."
	
	# Green Ethernet et al.
	
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Energy-Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Off" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Advanced EEE" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "EEE Control Policies" -DisplayValue "Maximum Performance" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Reduce Speed On Power Down" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "System Idle Power Saver" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Ultra Low Power Mode" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Gigabit Lite" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Power Saving Mode" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Enable PME" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null

	# Other general performance items
	
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Interrupt Moderation" -DisplayValue "Enabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Interrupt Moderation Rate" -DisplayValue "Adaptive" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Adaptive Inter-Frame Spacing" -DisplayValue "Enabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Auto Disable Gigabit" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "RSS Profile" -DisplayValue "NUMA Scaling Static" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "RSS load balancing profile" -DisplayValue "NUMAScalingStatic" -ErrorAction SilentlyContinue | Out-Null
	Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Virtual Machine Queues" -DisplayValue "Disabled" -ErrorAction SilentlyContinue | Out-Null

	try {
		$NICProperty = Get-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Maximum Number of RSS Queues"  -ErrorAction Stop
		$ValidValues = (Get-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Maximum Number of RSS Queues").ValidDisplayValues
		Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Maximum Number of RSS Queues" -DisplayValue $ValidValues[-1] -ErrorAction Stop
		# $ValidValues[-1] sets the last one in the list, i.e., the highest
		}
	catch {
		}
		
	try {
		$NICProperty = Get-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Max Number of RSS Processors"  -ErrorAction Stop
		$ValidValues = (Get-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Max Number of RSS Processors").ValidDisplayValues
		Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Max Number of RSS Processors" -DisplayValue $ValidValues[-1] -ErrorAction Stop
		# $ValidValues[-1] sets the last one in the list, i.e., the highest
		}
	catch {
		}
		
	# Intel only.  
	If ((Get-NetAdapter -Name $_.Name).InterfaceDescription -Match 'Intel') {
		Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Receive Buffers" -DisplayValue "2048" -ErrorAction SilentlyContinue | Out-Null
		Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Transmit Buffers" -DisplayValue "2048" -ErrorAction SilentlyContinue | Out-Null
		}	
		
	# HPE only.  
	If ((Get-NetAdapter -Name $_.Name).InterfaceDescription -Match 'HPE') {
		Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Receive Buffers" -DisplayValue "512" -ErrorAction SilentlyContinue | Out-Null
		Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Transmit Buffers" -DisplayValue "600" -ErrorAction SilentlyContinue | Out-Null
		}	

	}

""
"Turning off power management for USB root hubs..."

# Does not work for Intel USB 3.0 eXtensible, something odd about that one

$hubs = Get-WmiObject Win32_USBHub
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt)
{
  $IN = $p.InstanceName.ToUpper()
  foreach ($h in $hubs)
  {
    $PNPDI = $h.PNPDeviceID
                if ($IN -like "*$PNPDI*")
                {
                    $p.enable = $False
                    $p.psbase.put() | Out-Null
                }
  }
}

""

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








