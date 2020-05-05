Get-CimInstance -Query "Select * FROM Win32_LogicalDisk WHERE DriveType=3" | ForEach-Object {
	$DriveLetterID = $_.DeviceID
	$DriveLetter = $DriveLetterID.Trim(":")
	"Working on $DriveLetter ..."
	Optimize-Volume $DriveLetter
}
