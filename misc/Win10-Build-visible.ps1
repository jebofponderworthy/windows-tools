# This script is designed to upgrade Windows 10 1809 or before, to 1903.
# It requires path C:\0CDD\Windows-10-1903 exist, 
# and working 7z.exe and 64-bit rsync.exe be present there 
# with all needed DLLs.
#
# It unpacks the ISO instead of mounting it, because many
# machines have OEM ISO mount software which breaks
# Microsoft's built-in ISO mount capability.

""
"----------------------------------------------------------"
"----------------------------------------------------------"
"             Upgrade Windows 10 to build 1903"
"----------------------------------------------------------"
"----------------------------------------------------------"
""


""
"--------------------------"
"Prepare the environment..."
"--------------------------"
""

# This step resets permissions in our working directory.  
# Have seen several cases where this is necessary.
"Correct permissions..."
takeown /F C:\0CDD /R /D Y > $null
icacls C:\0CDD /reset /T > $null

# Create our working directory.
"Create working directory..."
mkdir C:\0CDD\Windows-10-1903\10UpgradeLogs -force > $null

# Now download the ISO to C:\0CDD\Windows-10-1903.
# Automate would not do it, FTP from LiquidWeb was not reliable enough.
# Currently using rsync from ponderworthy.com cloud-hosted virtual.

""
"----------------------------------------------------------"
"Download Windows 10/1903 ISO via rsync, 50 requests max..."
"----------------------------------------------------------"
""

pushd C:\0CDD\Windows-10-1903

$i = 1
while(1) {

	""
    "Request #$i ..."
	""
	
	if (Test-Path ".\SW_DVD9_Win_Pro_10_1903_64BIT_English_Pro_Ent_EDU_N_MLF_X22-02890.ISO" -PathType Leaf) {
		"ISO file already exists.  Comparing with download source..."
		}

	## The below uses a cloud-hosted virtual.  Working very well.
	# .\rsync.exe -z --compress-level=9 --inplace --progress `
	#	ponderworthy.com::cdd/SW_DVD9_Win_Pro_10_1903_64BIT_English_Pro_Ent_EDU_N_MLF_X22-02890.ISO .

	## The below uses a NAS at CDD set up for this purpose by Brad.  Working, bandwidth and CPU limited to one or
	## just possibly two downloads of this at once.
	# $env:RSYNC_PASSWORD = "ihurjkgf"
	# .\rsync.exe --inplace --progress `
	# 	rsync://array1_ISO@67.63.236.155/array1_ISO/SW_DVD9_Win_Pro_10_1903_64BIT_English_Pro_Ent_EDU_N_MLF_X22-02890.ISO .
	## At CDD, the IP of the NAS is 172.16.201.102.  There is a NAT to produce the above.
	
	## The below uses CBT-NAS, an rsync-enabled share.  The CDD NAS was running 250-800 KBps and timing out, this is running 1.5-2.5 MBps.
	## IP 68.101.33.11 has also been prepared with a NAT in the Watchguard for this, but 184 is the less-used ISP connection.
	$env:RSYNC_PASSWORD = "ihuXrj1kgf$%@!$"
	.\rsync.exe --inplace --progress -z `
	 	rsync://getwin10iso@184.179.97.138/WIN10ISO/SW_DVD9_Win_Pro_10_1903_64BIT_English_Pro_Ent_EDU_N_MLF_X22-02890.ISO .
	

	""
	"Check the ISO..."
	""

	$certrpt = (certutil -hashfile .\SW_DVD9_Win_Pro_10_1903_64BIT_English_Pro_Ent_EDU_N_MLF_X22-02890.ISO SHA256)[1] -replace '\s',''
	If ($certrpt -eq '50e0139646630f94d9036edaab1b91e9067741a196aa6205550659e867518bae') {
		""
		"ISO verified good via hash!  Moving onto next step."
		""
		break
		}
		
	"Hash check of the ISO failed!"
		
	$i += 1
	if ($i -gt 50) {
		""
		"50 download requests failed to complete.  Aborting."
		""
		exit(1)
		}
		
	"Continuing the download..."
	
	}
	
""
"---------------------------------------------------------"
"Unpack the ISO and prepare for initiation of install..."
"---------------------------------------------------------"
""

"Correct permissions again..."

takeown /F C:\0CDD /R /D Y > $null
icacls C:\0CDD /reset /T > $null

"Unpack..."

.\7z x ".\SW_DVD9_Win_Pro_10_1903_64BIT_English_Pro_Ent_EDU_N_MLF_X22-02890.ISO"

""
"-----------------------"
"Initiate the install..."
"-----------------------"
""

.\setup.exe /auto upgrade /showoobe none /copylogs C:\0CDD\Windows-10-1903\10UpgradeLogs
