#######################################################################
# GetRedists                                                          #
#                                                                     #
# Retrieve and install all of the Microsoft redistributable libraries #
# currently being supported, using the excellent VcRedist package.    #
#                                                                     #
# version 1.3                                                         #
#######################################################################

# Items needing work:
# - Command-line option for location of repo folder
# - Error handling; if errors occur at any stage, terminate and print.

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

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

$reportStatus = ''
$currentOp = ''
function ShowProgress {
	param( [string]$reportStatus, [string]$currentOp )

    Write-Progress -Activity "Get Microsoft Redists" -Status $reportStatus -PercentComplete -1 -CurrentOperation $currentOp
    }

ShowProgress("Preparing Powershell environment:","Installing NuGet Package Provider (for VcRedist)...")
Install-PackageProvider -Name NuGet -Force | Out-Null
ShowProgress("Preparing Powershell environment:","Installing NuGet (for VcRedist)...")
Install-Module -Name NuGet -SkipPublisherCheck -Force
ShowProgress("Preparing Powershell environment:","Importing NuGet (for VcRedist)...")
Import-Module -Name NuGet
ShowProgress("Preparing Powershell environment:","Installing VcRedist...")
Install-Module -Name VcRedist -SkipPublisherCheck -Force
ShowProgress("Preparing Powershell environment:","Importing VcRedist...")
Import-Module -Name VcRedist
ShowProgress("Preparing repo folder...","")
New-Item C:\VcRedist -ItemType Directory | Out-Null
ShowProgress("Retrieving all redistributables to repo folder...","")
Get-VcList | Get-VcRedist -Path C:\VcRedist | Out-Null
ShowProgress("Installing all redistributables from repo folder...","")
Get-VcList | Install-VcRedist -Path C:\VcRedist | Out-Null
ShowProgress("Removing repo folder...","")
Remove-Item C:\VcRedist -Recurse -Force | Out-Null
ShowProgress("Done!","")


