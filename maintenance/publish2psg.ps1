$NuGetKey = "14648dfc-93d6-4036-a045-e15032f41cf1"

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
ToPSGallery "CATE.ps1" "3.57" $Desc $ReleaseNotes

"GetRedists..."
$Desc = "GetRedists - Get all current Microsoft VC++ redistributables"
$ReleaseNotes = @(
	"GetRedists",
	"Retrieve and install all of the VC++ redistributable libraries",
	"currently being supported by Microsoft, using the excellent",
	"VcRedist package."
	)
ToPSGallery "GetRedists.ps1" "1.34" $Desc $ReleaseNotes

"OVSS..."
$Desc = "OVSS - optimizes VSS preallocation to 20% for each NTFS volume, and clears orphan shadows"
$ReleaseNotes = @(
	"OVSS",
	"Removes all orphan shadows, and then preallocates 20%",
	"of each drive volume for VSS as many different tools'",
	"docs advise."
	)
ToPSGallery "OVSS.ps1" "3.05" $Desc $ReleaseNotes

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
ToPSGallery "OWTAS.ps1" "3.06" $Desc $ReleaseNotes

"TweakNTFS..."
$Desc = "TweakNTFS - optimizes NTFS volumes for performance and reliability"
$ReleaseNotes = @(
	"TweakNTFS",
	"Tweaks all NTFS volumes on a system for",
	"performance and reliability, using FSUTIL"
	)
ToPSGallery "TweakNTFS.ps1" "2.14" $Desc $ReleaseNotes
	
"RunDevNodeClean..."
$Desc = "RunDevNodeClean - cleans unused device nodes in registry, improves performance"
$ReleaseNotes = @(
	"RunDevNodeClean",
	"Downloads the DevNodeClean package, chooses the binary appropriate to",
	"the bit-width of the current OS, and runs it.  This cleans unused",
	"device nodes in the registry, improving performance."
	)
ToPSGallery "RunDevNodeClean.ps1" "1.11" $Desc $ReleaseNotes

"TOSC..."
$Desc = "TOSC - Turn Off Share Caching"
$ReleaseNotes = @(
	"TOSC",
	"By default in Windows since XP/2003, if a folder is shared to the network via SMB,",
	'so-called "caching" is turned on. This actually means that the Offline Files service',
	"on other machines accessing the share, are allowed to retrieve and store copies of",
	"files and folders on the machine acting as server. Turning this off for all shares",
	"gives a speed bump for the server machine, and also improves reliability overall,",
	"dependence on Offline Files can lead to all sorts of issues including data loss",
	"when the server is not available or suddenly becomes available et cetera. TOSC does",
	"this turning off very well, for all file shares extant on the machine on which",
	"it is run."
	)
ToPSGallery "TOSC.ps1" "1.11" $Desc $ReleaseNotes
