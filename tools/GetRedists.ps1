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
Install-PackageProvider -Name NuGet -Force
Install-Module -Name NuGet -SkipPublisherCheck -Force
Import-Module -Name NuGet
Install-Module -Name VcRedist -SkipPublisherCheck -Force
Import-Module -Name VcRedist
New-Item C:\VcRedist -ItemType Directory
Get-VcList | Get-VcRedist -Path C:\VcRedist
Get-VcList | Install-VcRedist -Path C:\VcRedist
Remove-Item C:\VcRedist -Recurse -Force
