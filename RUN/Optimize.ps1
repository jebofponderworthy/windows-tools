#
# This version is good for interactive use on a PC.  It is more thorough than the automation-oriented version, because it
# assists with the user profile upon which it is run.
#
# This version does require that PREP4OPTIMIZE.CMD be run as administrator first, so that Powershell is prepared and
# the Authenticode certificate is installed, in order that security tools not give false alarms.
#

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
	
Set-ExecutionPolicy Bypass -Scope Process -Force

# Do not show download preference, this permits execution where cannot
$ProgressPreference = 'SilentlyContinue'

Import-Module BitsTransfer

$ps_script_list = @(
    'mma-appx-etc.ps1',
    'TweakMemTCP.ps1',
    'RunDevNodeClean.ps1',
    'wt_removeGhosts.ps1',
    'TweakNTFS.ps1',
    'OWTAS.ps1',
	'TOSC.ps1',
    'OVSS.ps1',
    'CATE.ps1'
    )

$wco = (New-Object System.Net.WebClient)

ForEach ($ps_script in $ps_script_list) {
	$download_url = "https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/$ps_script"

	""
	"--- Downloading $ps_script... ---"
	Invoke-WebRequest -Uri $download_url -Outfile ".\$ps_script"

	$run_script = ".\$ps_script"

	& $run_script
	Remove-Item ".\$ps_script"
	}
	
$wco.Dispose()

exit
