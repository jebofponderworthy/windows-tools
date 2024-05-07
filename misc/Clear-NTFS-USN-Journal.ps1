########################################
# Delete and Recreate NTFS USN Journal #
########################################

# This script iterates through all lettered NTFS drives in Windows, 
# and deletes and recreates the USN Journal of each one.
# Considerable performance gain results if the image has been running
# for a year or more.

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

	# Only does the operation on lettered, NTFS drives
	If (($DriveID -match "[A-Z]") -and
		((Get-WmiObject -Class Win32_Volume | Where-Object {$_.DriveLetter -eq $DriveID}).FileSystem -eq "NTFS"))
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