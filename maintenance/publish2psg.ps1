################################
# Publish 2 PowerShell Gallery #
###########################################################################
# Publishes all of the windows-tools to the Microsoft PowerShell Gallery. #
###########################################################################

# These encoding settings appear to result in UTF-8.  Don't ask me why, there might be some screaming involved.
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding =
                    New-Object System.Text.ASCIIEncoding
$PSDefaultParameterValues['*:Encoding'] = 'ascii'

$NuGetKey = "oy2jtj4ifoiyvt3biqfqdyaayia4sc7ujarnkacuaty4pm"

Function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

    Write-Progress -Activity "Get Microsoft Redists" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }

Function PrepareModule {
	param( [string]$ModuleName )
	
	If ((Find-Module -Name $ModuleName).Version -lt (Get-Module -Name $ModuleName -ListAvailable)) {
		Install-Module -Name $ModuleName -Repository PSGallery -Force
		}
	}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force > $null

ShowProgress("Preparing Powershell environment...","Setting up to use Powershell Gallery...")

Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

ShowProgress("Preparing Powershell environment:","Preparing PackageProvider NuGet...")
If ((Find-PackageProvider -Name NuGet).Version -lt (Get-PackageProvider -Name Nuget)) {
	Install-PackageProvider -Name NuGet -Force | Out-Null
	}

ShowProgress("Preparing Powershell environment...","Checking/preparing NuGet...")
PrepareModule("NuGet")

Function ToPSGallery {
	param( 	$psName, 
			$psDescription,
			$psReleaseNotes,
			$psTags,
			$psVersion
			)
	
	"Script:`t" + $psName
	"Description:`t" + $psDescription
	"Version:`t" + $psVersion
	
	Try { $OnlineInfo = Find-Script $psName -Repository PSGallery -ErrorAction SilentlyContinue | Out-Null }
	Catch {}
	If ($OnlineInfo -eq $null) {
		"$psName version $psVersion does not yet exist in PSGallery."
		}
	ElseIf ($OnlineInfo.Version -ge $psVersion) {
		"$psName version $psVersion or later, already exists in PSGallery."
		""
		return
		}
	
	$psFileName = ("..\tools\" + $psName + ".ps1")
	$psCopyRight = ('(c) ' + (Get-Date).year + ' Jonathan E. Brickman')
	
	"Updating $psFileName with metadata..."
	
	Update-ScriptFileInfo -Path $psFileName `
		-Author 'Jonathan E. Brickman' `
		-CompanyName 'Ponderworthy Music' `
		-Copyright $psCopyRight `
		-Description $psDescription `
		-LicenseURI 'https://opensource.org/licenses/BSD-3-Clause' `
		-ProjectURI 'https://github.com/jebofponderworthy/windows-tools' `
		-ReleaseNotes $psReleaseNotes `
		-Version $psVersion `
		-Force
	
	"Publishing ps1 file..."
	
	Publish-Script -Path $psFileName -NuGetApiKey $NuGetKey -Force
	
	""
	""
}

# ---------------------------------------

$Author = 'Jonathan E. Brickman'
$Desc = 'mma-appx-etc - performance gains of several kinds new to Windows 8/10/201*'
$Tags = @(
	'Lean Computing', 'Lean', 'Speed', 'Performance', 'Windows 10', 'Windows 8'
	)
$ReleaseNotes = @(
	'mma-appx-etc - performance gains of several kinds new to Windows 8/10/201*',
	'Configures MMAgent (including Superfetch, Memory Compression, etc.) for performance,',
	'removes several consumer-grade appx items, disables preload of Edge Browser,',
	'and disables Game Mode.'
	)
'mma-appx-etc' 
$Desc 
$ReleaseNotes 
$Tags 
'2.3'
ToPSGallery 'mma-appx-etc' $Desc $ReleaseNotes $Tags '2.3'

# ---------------------------------------

$Author = 'Jonathan E. Brickman'
$Desc = 'Clean All Temp Etc - cleans temporary files and folders from all standard user and system temp folders, clears logs, and more'
$Tags = @(
	'Cleanup', 'Clean', 'Temp', 'Temp Files', 'Temporary Files', 'Lean Computing', 'Lean', 'Speed', 'Performance'
	)
$ReleaseNotes = @(
	'CATE - Clean All Temp Etc',
	'Cleans temporary files and folders from all standard user temp folders,',
	'system profile temp folders, and system temp folders (they are not the same!);',
	'also clears logs, IE caches, Firefox caches, Chrome caches, Ask Partner Network data,',
	'Adobe Flash caches, Java deployment caches, and Microsoft CryptnetURL caches.'
	)
ToPSGallery 'CATE' $Desc $ReleaseNotes $Tags '4.7'

# ---------------------------------------

$Desc = 'TweakNTFS - optimizes NTFS volumes for performance and reliability'
$Tags = @(
	'NTFS', 'Performance', 'Reliability', 'Speed'
	)
$ReleaseNotes = @(
	'TweakNTFS',
	'Tweaks all NTFS volumes on a system for',
	'performance and reliability, using FSUTIL;'
	'also defrags NTFS metafiles using Contig.'
	)
ToPSGallery 'TweakNTFS' $Desc $ReleaseNotes $Tags '3.01'

# ---------------------------------------

$Desc = 'OVSS - optimizes VSS preallocation to 20% for each NTFS volume, and clears orphan shadows'
$Tags = @(
	'VSS', 'Optimize', 'Speed', 'Performance', 'Clean', 'VSS Association', 'Orphan Shadows'
	)
$ReleaseNotes = @(
	'OVSS',
	'Removes all orphan shadows, and then preallocates 20%',
	'of each drive volume for VSS, as docs for different tools',
	'advise.'
	)
ToPSGallery 'OVSS' $Desc $ReleaseNotes $Tags '3.7'

# ---------------------------------------

$Desc = 'GetRedists - Get all current Microsoft VC++ redistributables'
$Tags = @(
	'VC++', 'Redistributable', 'Redists', 'Redistributables', 'Microsoft Redistributable Libraries', 'Microsoft Redistributables', 'Microsoft VC++', 'Reliability'
	)
$ReleaseNotes = @(
	'GetRedists',
	'Retrieve, and install/update, all missing VC++ redistributable libraries',
	'currently being supported by Microsoft, using the excellent',
	'VcRedist module.'
	)
ToPSGallery 'GetRedists' $Desc $ReleaseNotes $Tags '2.8'

# ---------------------------------------

$Desc = 'OWTAS - enhances performance by adding threads. Optimizes critical and delayed worker threads and service work items.'
$Tags = @(
	'Speed', 'Performance', 'Memory', 'Threads', 'Worker Threads', 'Critical Worker Threads', 'Delayed Worker Threads', 'Service Work Items'
	)
$ReleaseNotes = @(
	'OWTAS',
	'This tool sets a number of additional critical and delayed worker threads,',
	'plus service work items. The changes are autocalculated according to a',
	'combination of RAM and OS bit-width (32 vs. 64). Performance will increase,',
	'more so with more RAM.',
	'',
	'Documentation on these settings has ranged from sparse to none over many years.',
	'The early Microsoft documents used in the calculations appear completely gone,',
	'there are some new ones. The settings produced by OWTAS have undergone testing',
	'over the last ten years, on a wide variety of Wintelamd platforms, and appear ',
	'to work well on all.'
	)
ToPSGallery 'OWTAS' $Desc $ReleaseNotes $Tags '3.8'

# ---------------------------------------

$Desc = 'RunDevNodeClean - cleans unused device nodes in registry, improves performance'
$Tags = @(
	'DevNodeClean', 'Unused Device Nodes', 'Device Nodes', 'Clean', 'Cleanup', 'Speed', 'Performance'
	)
$ReleaseNotes = @(
	'RunDevNodeClean',
	'Downloads the DevNodeClean package, chooses the binary appropriate to',
	'the bit-width of the current OS, and runs it.  This cleans unused',
	'device nodes in the registry, improving performance.'
	)
ToPSGallery 'RunDevNodeClean' $Desc $ReleaseNotes $Tags '1.13'

# ---------------------------------------

$Desc = 'TOSC - Turn Off Share Caching'
$Tags = @(
	'Offline Files', 'Caching', 'Speed', 'Performance'
	)
$ReleaseNotes = @(
	'TOSC',
	'By default in Windows since XP/2003, if a folder is shared to the network via SMB,',
	'so-called caching is turned on. This actually means that the Offline Files service',
	'on other machines accessing the share, are allowed to retrieve and store copies of',
	'files and folders on the machine acting as server. Turning this off for all shares',
	'gives a speed bump for the server machine, and also improves reliability overall,',
	'dependence on Offline Files can lead to all sorts of issues including data loss',
	'when the server is not available or suddenly becomes available et cetera. TOSC does',
	'this turning off very well, for all file shares extant on the machine on which',
	'it is run.'
	)
ToPSGallery 'TOSC' $Desc $ReleaseNotes $Tags '1.13'

# ---------------------------------------

$Desc = 'Windows-tools-performance-all - Retrieves, installs, and runs all clean/optimize/performance items of the windows-tools project.'
$Tags = @(
	'Cleanup', 'Clean', 'Temp', 'Temp Files', 'Temporary Files', 'Lean Computing', 'Lean', 'Speed', 'Performance', 'Optimize',
	'VSS', 'VSS Association', 'Orphan Shadows',
	'Memory', 'Threads', 'Worker Threads', 'Critical Worker Threads', 'Delayed Worker Threads', 'Service Work Items',
	'NTFS', 'Reliability',
	'DevNodeClean', 'Unused Device Nodes', 'Device Nodes',
	'Offline Files', 'Caching'
	)
$ReleaseNotes = @(
	'windows-tools-performance-all',
	'Retrieves, installs, and runs all clean/optimize/performance items of the windows-tools project,'
	'which do many different things to clean up and improve performance and reliability of any'
	'Microsoft-supported desktop or server Windows system.'
	)
ToPSGallery 'windows-tools-performance-all' $Desc $ReleaseNotes $Tags '1.2'

# ---------------------------------------

$Desc = 'Windows-tools-performance-most - Retrieves, installs, and runs all clean/optimize/performance items of the windows-tools project, including all but TOSC (Turn Off Share Caching).'
$Tags = @(
	'Cleanup', 'Clean', 'Temp', 'Temp Files', 'Temporary Files', 'Lean Computing', 'Lean', 'Speed', 'Performance', 'Optimize', 
	'VSS', 'VSS Association', 'Orphan Shadows', 
	'Memory', 'Threads', 'Worker Threads', 'Critical Worker Threads', 'Delayed Worker Threads', 'Service Work Items', 
	'NTFS', 'Reliability', 
	'DevNodeClean', 'Unused Device Nodes', 'Device Nodes'
	)

$ReleaseNotes = @(
	'windows-tools-performance-most',
	'Retrieves, installs, and runs all clean/optimize/performance items of the windows-tools project,',
	'including all but TOSC (Turn Off Share Caching).  These do many different things to clean up and',
	'improve performance and reliability of any Microsoft-supported desktop or server Windows system.'
	)
ToPSGallery 'windows-tools-performance-most' $Desc $ReleaseNotes $Tags '1.2'