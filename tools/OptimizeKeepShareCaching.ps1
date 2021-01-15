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

Import-Module BitsTransfer

$ps_script_list = @(
    'mma-appx-etc.ps1',
    'TweakMemTCP.ps1',
    'RunDevNodeClean.ps1',
    'wt_removeGhosts.ps1',
    'TweakDrives.ps1',
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

# 
# $wco.DownloadFile('http://privateftp.centuryks.com.php73-36.phx1-1.websitetestlink.com/privateftp/mma-appx-etc.ps1','mma-appx-etc.ps1')
# iex .\mma-appx-etc.ps1
# Remove-Item .\mma-appx-etc.ps1
# 

exit

# SIG # Begin signature block
# MIIQIQYJKoZIhvcNAQcCoIIQEjCCEA4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXO/NJo4o7G3GcpCwvaGXIKVr
# a5CgggupMIIDDDCCAfSgAwIBAgIQWcUlqk4xHLVNXPNwhVj6/zANBgkqhkiG9w0B
# AQsFADAeMRwwGgYDVQQDDBNDQlQgUG93ZXJTaGVsbCBDb2RlMB4XDTIwMDgxMjE2
# MDcyNVoXDTI1MDgxMjE2MTcyNVowHjEcMBoGA1UEAwwTQ0JUIFBvd2VyU2hlbGwg
# Q29kZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMm7TLZL9nQALtQ3
# 8aHm49IPMOTs37HK6y3h/I3NHbOQU+KPIjIFKBdj63UkPeC0x2+0O05ufdMbpNGa
# EujuCQtQ0+It0r8tItTct9d/MVBkFuPRMV0Tpr6jHVBv6CNwUNLFahfc8DtresaL
# hfu327IdapBNh7dLBYNo3BLX3elvLpOIqEVLzFeOnD9W5lZZCRX+dI4if6jzfafA
# 063Aw5/zQMxEJRLTEIuWZgTBmF6r4mcl8XxWdS0gq+NQOnDHi8ygVY9ktkG8YEY+
# WPtVhFC8hZjsPCvYM+cloa68voOLX0MCJiyxHRvj3JrdhchmHXLBAUAF5JtLn1zF
# UaaFkTkCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBROCAW1qiacSlOhPlDeYzaqhR5HVTANBgkqhkiG9w0BAQsF
# AAOCAQEAATm3sYZQfPXt2c6EowXij/7fqAUtOuGmxeH4ViXTuVk5fy7x8lnmoc/F
# DN8XwQEPlBH/lzxh5Qu6kMqU+IcMJE9uHKOzHdKjKOq06LfQtkXwkeLle+/EB2/Y
# /75x3ZV+02L1/+2p/tmg2KoGIU9vJa5IEwz/f5tYzdxu6ji14ZH1wrvhfRqoeS/Q
# fqKOJCBPoWy4zmBx/9zXOyTrdl8QpcBP5VsHXDrNIio6VVyrAL4ISyR0MwuhKoNT
# B1lKwHPkg8SYClfqt9fM/XREUIjisF88xyqZBJnkSdgL4Y2ag7xReQ/wUATCs9+a
# EhXxAdYoGdgieWB9Pi4TKjNjAcjKhDCCA+4wggNXoAMCAQICEH6T6/t8xk5Z6kua
# d9QG/DswDQYJKoZIhvcNAQEFBQAwgYsxCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxX
# ZXN0ZXJuIENhcGUxFDASBgNVBAcTC0R1cmJhbnZpbGxlMQ8wDQYDVQQKEwZUaGF3
# dGUxHTAbBgNVBAsTFFRoYXd0ZSBDZXJ0aWZpY2F0aW9uMR8wHQYDVQQDExZUaGF3
# dGUgVGltZXN0YW1waW5nIENBMB4XDTEyMTIyMTAwMDAwMFoXDTIwMTIzMDIzNTk1
# OVowXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9u
# MTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0g
# RzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCxrLNJVEuXHBIK2CV5
# kSJXKm/cuCbEQ3Nrwr8uUFr7FMJ2jkMBJUO0oeJF9Oi3e8N0zCLXtJQAAvdN7b+0
# t0Qka81fRTvRRM5DEnMXgotptCvLmR6schsmTXEfsTHd+1FhAlOmqvVJLAV4RaUv
# ic7nmef+jOJXPz3GktxK+Hsz5HkK+/B1iEGc/8UDUZmq12yfk2mHZSmDhcJgFMTI
# yTsU2sCB8B8NdN6SIqvK9/t0fCfm90obf6fDni2uiuqm5qonFn1h95hxEbziUKFL
# 5V365Q6nLJ+qZSDT2JboyHylTkhE/xniRAeSC9dohIBdanhkRc1gRn5UwRN8xXnx
# ycFxAgMBAAGjgfowgfcwHQYDVR0OBBYEFF+a9W5czMx0mtTdfe8/2+xMgC7dMDIG
# CCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AudGhhd3RlLmNv
# bTASBgNVHRMBAf8ECDAGAQH/AgEAMD8GA1UdHwQ4MDYwNKAyoDCGLmh0dHA6Ly9j
# cmwudGhhd3RlLmNvbS9UaGF3dGVUaW1lc3RhbXBpbmdDQS5jcmwwEwYDVR0lBAww
# CgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgEGMCgGA1UdEQQhMB+kHTAbMRkwFwYD
# VQQDExBUaW1lU3RhbXAtMjA0OC0xMA0GCSqGSIb3DQEBBQUAA4GBAAMJm495739Z
# MKrvaLX64wkdu0+CBl03X6ZSnxaN6hySCURu9W3rWHww6PlpjSNzCxJvR6muORH4
# KrGbsBrDjutZlgCtzgxNstAxpghcKnr84nodV0yoZRjpeUBiJZZux8c3aoMhCI5B
# 6t3ZVz8dd0mHKhYGXqY4aiISo1EZg362MIIEozCCA4ugAwIBAgIQDs/0OMj+vzVu
# BNhqmBsaUDANBgkqhkiG9w0BAQUFADBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMU
# U3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3Rh
# bXBpbmcgU2VydmljZXMgQ0EgLSBHMjAeFw0xMjEwMTgwMDAwMDBaFw0yMDEyMjky
# MzU5NTlaMGIxCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjE0MDIGA1UEAxMrU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBT
# aWduZXIgLSBHNDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKJjCzlE
# uLsjp0RJuw7/ofBhClOTsJjbrSwPSsVu/4Y8U1UPFc4EPyv9qZaW2b5heQtbyUyG
# duXgQ0sile7CK0PBn9hotI5AT+6FOLkRxSPyZFjwFTJvTlehroikAtcqHs1L4d1j
# 1ReJMluwXplaqJ0oUA4X7pbbYTtFUR3PElYLkkf8q672Zj1HrHBy55LnX80QucSD
# ZJQZvSWA4ejSIqXQugJ6oXeTW2XD7hd0vEGGKtwITIySjJEtnndEH2jWqHR32w5b
# MotWizO92WPISZ06xcXqMwvS8aMb9Iu+2bNXizveBKd6IrIkri7HcMW+ToMmCPsL
# valPmQjhEChyqs0CAwEAAaOCAVcwggFTMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
# BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeAMHMGCCsGAQUFBwEBBGcwZTAq
# BggrBgEFBQcwAYYeaHR0cDovL3RzLW9jc3Aud3Muc3ltYW50ZWMuY29tMDcGCCsG
# AQUFBzAChitodHRwOi8vdHMtYWlhLndzLnN5bWFudGVjLmNvbS90c3MtY2EtZzIu
# Y2VyMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly90cy1jcmwud3Muc3ltYW50ZWMu
# Y29tL3Rzcy1jYS1nMi5jcmwwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVT
# dGFtcC0yMDQ4LTIwHQYDVR0OBBYEFEbGaaMOShQe1UzaUmMXP142vA3mMB8GA1Ud
# IwQYMBaAFF+a9W5czMx0mtTdfe8/2+xMgC7dMA0GCSqGSIb3DQEBBQUAA4IBAQB4
# O7SRKgBM8I9iMDd4o4QnB28Yst4l3KDUlAOqhk4ln5pAAxzdzuN5yyFoBtq2MrRt
# v/QsJmMz5ElkbQ3mw2cO9wWkNWx8iRbG6bLfsundIMZxD82VdNy2XN69Nx9DeOZ4
# tc0oBCCjqvFLxIgpkQ6A0RH83Vx2bk9eDkVGQW4NsOo4mrE62glxEPwcebSAe6xp
# 9P2ctgwWK/F/Wwk9m1viFsoTgW0ALjgNqCmPLOGy9FqpAa8VnCwvSRvbIrvD/niU
# UcOGsYKIXfA9tFGheTMrLnu53CAJE3Hrahlbz+ilMFcsiUk/uc9/yb8+ImhjU5q9
# aXSsxR08f5Lgw7wc2AR1MYID4jCCA94CAQEwMjAeMRwwGgYDVQQDDBNDQlQgUG93
# ZXJTaGVsbCBDb2RlAhBZxSWqTjEctU1c83CFWPr/MAkGBSsOAwIaBQCgeDAYBgor
# BgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEE
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR+
# JABkADEjtT7Y4dwFKqzMBv7+dDANBgkqhkiG9w0BAQEFAASCAQASVuGJtwtykWNv
# AWtWbNZDvSpxBfpvqeum1QhbjWI3Fh8sFNUELiya6phTu2aJFj3rbadIGlRH9mBw
# 8f+aave5LoBEMUdXzVnTq27mRW38Wzt6/qoF/j2rUzxkWr4DI3ZQVjVQwzX9b0kQ
# pO691JqTxf0nrB/tjRl8vxIgx8Y1RVKO3Uc2jbvUCYyo56EP9tt5gqGhx95P9Wsz
# xX2754z0+0hWYrQd0+QcrMzCJ45Vrt4D9ABRIXkuqvaxkeiFzqWn3aTHIg7kYqkF
# Sa9NpMOOqYWlnHuOW6087OW+JsslU69lkJpUfgytgG2fsXe+tjuruDG/dWeLBuyQ
# MaD56O/WoYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81
# bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
# HAYJKoZIhvcNAQkFMQ8XDTIwMDgxMjE2MTczM1owIwYJKoZIhvcNAQkEMRYEFLyU
# rbUSQgT7ZBeF0OmU2aYNsUJMMA0GCSqGSIb3DQEBAQUABIIBAHDH/WVOnv8sJZjU
# 1cDi1UpI8Q5FTDssmTX07NiVRYIT5qpajLgd51Fx2KVbS4iYD2rTmcdg4TUklDQt
# wjf8jzVsLMp6m0nrdNJnfDQ6tF2IXI3SiPTG5vIoKc/vLFnPHMds8WSEDg9B1FTv
# utXwqE5hitWx8omIjinWxyh7FSqhUfpHpWfhMb9lxMEbWK1Std2Tuuid3Zf65Ba8
# WpfrKCncA4/E+Xi6DImKT+wuHwmLa6ZmeGOL6Utvqoayhle1YYwrZoy/d/Y8vB0n
# 2jR6hznqdGTMwxf5J5YuxlEg1vGJDMRpRzmLiJIoLG1kU3NGUFtI38mbvc2WbIpP
# yeatzZ4=
# SIG # End signature block
