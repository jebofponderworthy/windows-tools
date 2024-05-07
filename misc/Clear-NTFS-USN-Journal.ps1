#####################
# Clear USN Journal #
#####################

# This script clears the USN Journal of all lettered drives in Windows.
# Considerable performance gain results if the image has been running
# for years.

# There are slightly different commands between some OS versions.
$OSVer = [System.Environment]::OSVersion.Version
If ($OSVer.Major -gt 10)
{
	"OS > 10. Create uses short command."
	$ShortCommand = $True
} ElseIf ($OSVer.Major -eq 10) {
	If ($OSVer.Build -le 14393)	{
		("OS is 10 build " + $OSVer.Build + ". " + "Create uses long command.")
		$ShortCommand = $False
	}
	Else {
		"OS is 10, build > 14393. Create uses short command."
		$ShortCommand = $True
	}
} ElseIf ($OSVer.Major -lt 10) {
	"OS < 10. Create uses long command."
	$ShortCommand = $False
}	

Get-CimInstance -Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" | ForEach-Object {
	$DriveID = $_.DeviceID

	If ($DriveID -match "[A-Z]")
	{
		"Clearing USN Journal for " + $DriveID + " ..."
		fsutil usn deletejournal /n $DriveID

		"Recreating USN Journal for " + $DriveID + " ..."
		if ($ShortCommand) {
			fsutil usn createjournal $DriveID
		}
		else {
			fsutil usn createjournal m=1000 a=100 $DriveID
		}
	}
}
# End Script