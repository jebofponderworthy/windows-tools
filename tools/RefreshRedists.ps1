Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
Install-Module -Name NuGet -Force
Import-Module -Name NuGet
Install-Module -Name VcRedist -Force
Import-Module -Name VcRedist
New-Item C:\VcRedist -ItemType Directory
Get-VcList | Get-VcRedist -Path C:\VcRedist
Get-VcList | Install-VcRedist -Path C:\VcRedist
