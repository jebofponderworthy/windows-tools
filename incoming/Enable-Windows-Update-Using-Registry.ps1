
New-ItemProperty -Path "HKLM:\System\Internet Communication Management\Internet Communication" -Name "DisableWindowsUpdateAccess" -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableWindowsUpdateAccess" -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoWindowsUpdate" -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" -Name "DisableWindowsUpdateAccess" -Value 0 -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" -Name "DisableWindowsUpdateAccessMode" -Value 0 -Force
New-PSDrive HKU Registry HKEY_USERS
Set-Location HKU:\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Policies
New-Item -Path ".\WindowsUpdate"
Set-Location ".\WindowsUpdate"
New-ItemProperty -Path "." -Name "DisableWindowsUpdateAccess" -Value 0 -Force
