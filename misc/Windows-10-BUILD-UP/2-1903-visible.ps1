$note=@'
This script is designed to perform a Windows 10 build upgrade.

Requirements:

1. This script has to reside in folder C:\0CBT\Windows-10-BUILD-UP,
along with 7z.exe with all needed DLLs.

2. The ISO for the upgrade has be present in the folder also,
and be renamed WIN10BUILD.ISO.  The current ISO can be downloaded here:
https://www.microsoft.com/en-us/software-download/windows10
but it may not be the most current that you want.  To choose
the build you will download, try this:
https://tb.rg-adguard.net/public.php
It's a third-party site, but the downloads come straight from Microsoft.

It unpacks the ISO instead of mounting it, because many
machines have OEM ISO mount software which breaks
Microsoft's built-in ISO mount capability.
'@

$note

''
''
'-----------------------------------------------------'
'-----------------------------------------------------'
'             Windows 10 Build Upgrade'
'-----------------------------------------------------'
'-----------------------------------------------------'
''


''
'--------------------------'
'Prepare the environment...'
'--------------------------'
''

# This step resets permissions in our working directory.  
# Have seen several cases where this is necessary.
'Correct permissions...'
takeown /F C:\0CBT /R /D Y > $null
icacls C:\0CBT /reset /T > $null

# Create our working directory.
'Create working directory...'
mkdir C:\0CBT\Windows-10-BUILD-UP\10UpgradeLogs -force > $null

	
''
'---------------------------------------------------------'
'Unpack the ISO and prepare for initiation of install...'
'---------------------------------------------------------'
''

'Correct permissions again...'

takeown /F C:\0CBT /R /D Y > $null
icacls C:\0CBT /reset /T > $null

'Unpack...'

.\7z x '.\WIN10BUILD.ISO'

''
'-----------------------'
'Initiate the install...'
'-----------------------'
''

.\setup.exe /auto upgrade /showoobe none /copylogs C:\0CBT\Windows-10-BUILD-UP\10UpgradeLogs
