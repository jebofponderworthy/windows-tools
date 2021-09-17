Instructions:

1. This script has to reside in folder C:\0CBT\Windows-10-BUILD-UP,
along with 7z.exe with all needed DLLs.

2. The ISO for the upgrade has be present in the folder also,
and be renamed WIN10BUILD.ISO.  The current ISO can be downloaded here:
https://www.microsoft.com/en-us/software-download/windows10
but it may not be the most current that you want.  To choose
the build you will download, try this:
https://tb.rg-adguard.net/public.php
It's a third-party site, but the downloads come straight from Microsoft.
3. To run the script, do the following:
	a.  Open an administrative Powershell
	b.  set-executionpolicy bypass -scope process
	c.  CD C:\0CBT\Windows-10-BUILD-UP
	d.  .\2-1903-visible-ps1
