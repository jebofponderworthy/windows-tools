# ******************************************** '
# Delete Drive Mappings from All User Profiles '
# *********************************************'

# HKEY_USERS is not addressable as a PSDrive by default, but we can fix that
New-PSDrive -PSProvider Registry -Name HKEY_USERS -Root HKEY_USERS

# Iterate through all folders in HKEY_USERS
Set-Location "HKEY_USERS:\"
Get-ChildItem | ForEach-Object {
	"Descending into " + "HKEY_USERS:\" + $_.PSChildName
	Set-Location ("HKEY_USERS:\" + $_.PSChildName)
	
	# Descend into folder Network if exists, otherwise
	# go to next top-level
	if (Test-Path -Path "Network")
		{
		"Working on" + $_.PSChildName
		Set-Location -Path "Network" 
		}
	Else
		{ Continue }

	# Inside each, iterate through all folders again
	Get-ChildItem | ForEach-Object {
		$_.PSChildName
		If ($_.PSChildName.Length -eq 1)
			{ 
			"Removing " + $_.PSChildName
			Remove-Item -Path $_ -Recurse -Force
			}
	}
}
