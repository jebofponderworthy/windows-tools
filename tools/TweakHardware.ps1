
<#PSScriptInfo

.VERSION 1.5

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


























Param()


##############################################################
# Tweak Hardware: NIC performance, disable USB power saving, #
# and printer spooler cleanup                            #
##############################################################

#
# by Jonathan E. Brickman
#
# Tweaks NIC(s) for performance, and disables power saving for all
# USB devices, and also does a very special cleanup of the Windows printer spooler.
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
" TweakHardware: Tweak NICs for performance, disable USB power saving,   "
" and printer spooler cleanup "
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

"Disabling Fast Startup..."
powercfg /hibernate off
""

# Get-NetAdapterAdvancedProperty gets a full list, for all NICs on a given machine.
# The below combines settings across multiple NIC types, most settings will not apply
# to all NICs.

# To get a list of valid values for many given items, example:
# $ValidValues = (Get-NetAdapterAdvancedProperty -Name "NIC Name" -DisplayName "Energy-Efficient Ethernet").ValidDisplayValues

# Performance tuning information comes from:
# https://docs.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-nics
# https://docs.microsoft.com/en-us/search/?terms=Performance%20Tuning%20Network%20Adapters
# and others

function Set-NIC-Property {
	param( [string]$NICName, [string]$PropertyName, [string]$PropertySetting )
	
	# Try to make the setting.  If the requested setting is valid and successful, report.
	# Otherwise don't care.
	
	try {
		Set-NetAdapterAdvancedProperty -Name $NICName -DisplayName $PropertyName -DisplayValue $PropertySetting -ErrorAction Stop | Out-Null
		}
	catch {
		return
		}
		
	"On NIC <$NICName>, set <$PropertyName> to <$PropertySetting>."
	}
	
function Set-NIC-Property-Highest {
	param( [string]$NICName, [string]$PropertyName )

	try {
		$NICProperty = Get-NetAdapterAdvancedProperty -Name $NICName -DisplayName $PropertyName  -ErrorAction Stop
		$ValidValues = (Get-NetAdapterAdvancedProperty -Name $NICName -DisplayName $PropertyName).ValidDisplayValues
		Set-NIC-Property $NICName $PropertyName $ValidValues[-1]
		# $ValidValues[-1] sets the last one in the list, i.e., the highest
		}
	catch {
		return
		}
	}

Get-NetAdapter | ForEach-Object {
	"Checking NIC <" + $_.Name + "> ..."
	
	# Green Ethernet et al.
	
	Set-NIC-Property $_.Name "Energy-Efficient Ethernet" "Disabled"
	Set-NIC-Property $_.Name "Energy Efficient Ethernet" "Off"
	Set-NIC-Property $_.Name "Advanced EEE" "Disabled"
	Set-NIC-Property $_.Name "EEE Control Policies" "Maximum Performance"
	Set-NIC-Property $_.Name "Reduce Speed On Power Down" "Disabled"
	Set-NIC-Property $_.Name "System Idle Power Saver" "Disabled"
	Set-NIC-Property $_.Name "Ultra Low Power Mode" "Disabled"
	Set-NIC-Property $_.Name "Green Ethernet" "Disabled"
	Set-NIC-Property $_.Name "Gigabit Lite" "Disabled"
	Set-NIC-Property $_.Name "Power Saving Mode" "Disabled"
	Set-NIC-Property $_.Name "Enable PME" "Disabled"
	Set-NIC-Property $_.Name "Reduce link speed to save power" "Disabled"

	# Other general performance items
	
	Set-NIC-Property $_.Name "Interrupt Moderation" "Enabled"
	Set-NIC-Property $_.Name "Interrupt Moderation Rate" "Adaptive"
	Set-NIC-Property $_.Name "Adaptive Inter-Frame Spacing" "Enabled"
	Set-NIC-Property $_.Name "Auto Disable Gigabit" "Disabled"
	Set-NIC-Property $_.Name "RSS Profile" "NUMA Scaling Static"
	Set-NIC-Property $_.Name "RSS load balancing profile" "NUMAScalingStatic"
	Set-NIC-Property $_.Name "Virtual Machine Queues" "Disabled"
	
	Set-NIC-Property-Highest $_.Name "Maximum Number of RSS Queues"
	Set-NIC-Property-Highest $_.Name "Max Number of RSS Processors"
	Set-NIC-Property-Highest $_.Name "Maximum Number of RSS Processors"
	
	# Some wifi items
	
	Set-NIC-Property $_.Name "MIMO Power Save Mode" "No SMPS"
	Set-NIC-Property $_.Name "Roaming Aggressiveness" "4. Medium-High"
	Set-NIC-Property $_.Name "Throughput Booster" "Enabled"
	Set-NIC-Property $_.Name "Transmit Power" "5. Highest"
	
	# Vendor specific...
		
	$NICDescription = (Get-NetAdapter -Name $_.Name).InterfaceDescription
		
	# Intel only.  
	If ($NICDescription -Match 'Intel') {
		Set-NIC-Property $_.Name "Receive Buffers" "2048"
		Set-NIC-Property $_.Name "Transmit Buffers" "2048"
		}	
		
	# Broadcom.
	If ($NICDescription -Match 'Broadcom') {
		Set-NIC-Property $_.Name "Receive Buffers" "Maximum"
		Set-NIC-Property $_.Name "Transmit Buffers" "600"
		}	
	
		
	# HPE and HP can be Intel and others, with different number sets.  
	# Set low first, high second, high will not go in if does not fit.
	# There are also other limitations in some NICs, e.g., multiples of 8.
	If ($NICDescription -Match 'HP' ) {

		Set-NIC-Property $_.Name "Receive Buffers" "512"
		Set-NIC-Property $_.Name "Transmit Buffers" "600"

		Set-NIC-Property $_.Name "Receive Buffers" "2048"
		Set-NIC-Property $_.Name "Transmit Buffers" "2048"

		Set-NIC-Property $_.Name "Receive Buffers" "Maximum"
		Set-NIC-Property $_.Name "Transmit Buffers" "Maximum"
		
		Set-NIC-Property $_.Name "Receive Buffers (0=Auto)" "35000"
		Set-NIC-Property $_.Name "Transmit Buffers (0=Auto)" "5000"

		}	

	if ($NICDescription -Match 'Microsoft Hyper-V') {

		Set-NIC-Property-Highest $_Name "Send Buffer Size"
		Set-NIC-Property-Highest $_Name "Receive Buffer Size"
		
		}
		
	}

""
"Turning off power management for USB root hubs and controllers..."


# This seems to work for a lot of them.  

# Not using Get-CimObject because some hardware does not work with that.

# This seems to list all relevant devices:
# gwmi -list | ?{ $_.Name -cmatch "USB" }

$hubs = Get-WmiObject Win32_USBHub
$counthubs = $hubs.Count
"Setting for $counthubs USB hubs."
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

$Controllers = Get-WmiObject Win32_USBController
$ControllerCount = $Controllers.Count
"Setting for $ControllerCount USB controllers."
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt)
{
  $IN = $p.InstanceName.ToUpper()
  foreach ($h in $Controllers)
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
"Performing special cleanup of Windows printer spooler registry area..."

function Remove-AllItemProperties
{
    [CmdletBinding()]
    param([string]$Path)

    Remove-ItemProperty -Name * @PSBoundParameters
}

Remove-AllItemProperties "HKCU:\SOFTWARE\microsoft\windows nt\currentversion\devices"

Stop-Service Spooler
Start-Service Spooler

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








