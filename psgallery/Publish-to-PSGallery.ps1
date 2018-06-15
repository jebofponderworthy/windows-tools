$NuGetKey = "6f05b805-b551-403f-9b05-b45fb420c69b"

Function ToPSGallery {
	param( 	[string]$ps1, 
			[string]$ps1Version,
			[string]$ps1Description,
			$ps1ReleaseNotes
			)
	
	Update-ScriptFileInfo -Path "..\tools\$ps1" -Version $ps1Version `
	-Author "Jonathan E. Brickman" `
	-Description $ps1Description `
	-ReleaseNotes $ps1ReleaseNotes `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force
	
	Publish-Script -Path "..\tools\$ps1" -NuGetApiKey $NuGetKey
}

"CATE..."
$Desc = "Clean All Temp Etc - cleans temporary files and folders from all standard user and system temp folders, clears logs, and more"
$ReleaseNotes = @(
	"CATE - Clean All Temp Etc",
	"Cleans temporary files and folders from all standard user temp folders,",
	"system profile temp folders, and system temp folders (they are not the same!);",
	"also clears logs, IE caches, Firefox caches, Chrome caches, Ask Partner Network data,",
	"Adobe Flash caches, Java deployment caches, and Microsoft CryptnetURL caches."
	)
ToPSGallery "CATE.ps1" "3.55" $Desc $ReleaseNotes

"GetRedists..."
$Desc = "GetRedists - Get all current Microsoft VC++ redistributables"
$ReleaseNotes = @(
	"GetRedists",
	"Retrieve and install all of the VC++ redistributable libraries",
	"currently being supported by Microsoft, using the excellent",
	"VcRedist package."
	)
ToPSGallery "GetRedists.ps1" "1.32" $Desc $ReleaseNotes

"OVSS..."
$Desc = "OVSS - optimizes VSS preallocation to 20% for each NTFS volume, and clears orphan shadows"
$ReleaseNotes = @(
	"OVSS",
	"Removes all orphan shadows, and then preallocates 20%",
	"of each drive volume for VSS as many different tools'",
	"docs advise."
	)
ToPSGallery "OVSS.ps1" "1.01" $Desc $ReleaseNotes

"OWTAS..."
$Desc = "OWTAS - enhances performance by adding threads. Optimizes critical and delayed worker threads and service work items."
$ReleaseNotes = @(
	"OWTAS",
	"This tool sets a number of additional critical and delayed worker threads,",
	"plus service work items. The changes are autocalculated according to a",
	"combination of RAM and OS bit-width (32 vs. 64). Performance will increase,",
	"more so with more RAM.",
	"",
	"Documentation on these settings has ranged from sparse to none over many years. ",
	"The early Microsoft documents used in the calculations appear completely gone,",
	"there are some new ones. The settings produced by OWTAS have undergone testing",
	"over the last ten years, on a wide variety of Wintelamd platforms, and appear ",
	"to work well on all."
	)
ToPSGallery "OVSS.ps1" "3.02" $Desc $ReleaseNotes

"TweakNTFS..."
$Desc = "TweakNTFS - optimizes NTFS volumes for performance and reliability"
$ReleaseNotes = @(
	"TweakNTFS",
	"Tweaks all NTFS volumes on a system for",
	"performance and reliability, using FSUTIL"
	)
ToPSGallery "TweakNTFS.ps1" "2.12" $Desc $ReleaseNotes
	
