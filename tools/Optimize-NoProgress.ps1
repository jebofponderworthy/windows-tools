
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

# Do not show progress, this permits execution where otherwise cannot,
# e.g., within certain scripting environments
$ProgressPreference = 'SilentlyContinue'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12;

Import-Module BitsTransfer

$ps_script_list = @(
    'mma-appx-etc.ps1',
    'TweakMemTCP.ps1',
    'RunDevNodeClean.ps1',
    'wt_removeGhosts.ps1',
    'TweakDrives.ps1',
	'TweakSMB.ps1',
    'OWTAS.ps1',
    'OVSS.ps1',
    'CATE.ps1',
	'TweakHardware.ps1'
    )

$wco = (New-Object System.Net.WebClient)

ForEach ($ps_script in $ps_script_list) {
	$download_url = "https://github.com/jebofponderworthy/windows-tools/raw/master/tools/$ps_script"

	""
	"--- Downloading $ps_script... ---"
	Invoke-WebRequest -Uri $download_url -Outfile ".\$ps_script"
	
	$run_script = ".\$ps_script"

	& $run_script
	Remove-Item ".\$ps_script"
	}
	
$wco.Dispose()

exit
