# Self-elevate if not already elevated.
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

# Sets TLS version.  Necessary for some platforms.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

	Write-Progress -Activity "Get Microsoft Redistributables" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
	# Write-Progress is not compatible with some remote shell methods.

}

Function PrepareModule {
	param( [string]$ModuleName )

	If (Get-Module -ListAvailable -Name $ModuleName)
		{ Update-Module $ModuleName }
	Else
		{ Install-Module $ModuleName }
	}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force > $null

'Preparing Powershell environment...'

ShowProgress("Preparing Powershell environment...","Setting up to use Powershell Gallery...")

ShowProgress("Preparing Powershell environment:","Setting up to use page provider NuGet...")
Install-PackageProvider -Name NuGet -Force | Out-Null

# This appears to set PSGallery nicely when need be
Register-PSRepository -Default -InstallationPolicy Trusted 2> $null
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery

ShowProgress("Preparing Powershell environment...","Checking/preparing module NuGet...")
PrepareModule("NuGet")
ShowProgress("Preparing Powershell environment...","Checking/preparing module ExchangeOnlineManagement...")
PrepareModule("ExchangeOnlineManagement")



