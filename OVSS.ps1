#################################
#           Optimize VSS        #
#                               #
# v1.0 by Jonathan E. Brickman  #
#                               #
# Removes all orphan shadows,   #
# and then preallocates 20%     #
# of each hard drive for VSS    #
# as many different tools' docs #
# advise.                       #
#################################

"OVSS: Optimize VSS"
"v1.0"
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


