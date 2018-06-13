###########################################################################################################
#
# Run-script autobuilder 
# v2.2
#
##############################
#
# This script requires PowerShell 5.1 or higher.  
# Its result is CMD files, which require PowerShell 3.0 or higher.
#
# Github stores its files in treelevels, per history.  For instance this:
# 
# $githubURL = "https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/3c2c39050bfc55d307705dd1ed9863712bcc2dcc/"
#
# brings up the whole repository, all files, as they existed at a certain time, May 14, 2018.  Such
# a URL can be had from any file page in the repository.  To get such a URL:
#
# 1. Open a file that has been updated on a day whose snapshot you want to see, by clicking its link.
# 2. Click on History.
# 3. In the rightmost column on the History page, there are links marked "<>" for each snapshot.
#    If you hover over one of these, it will say "Browse the repository in this point in the history."
#    Click the appropriate one.
# 4. Github sends you to browse the root of the snapshot.  Browse to and open the file again, within
#    the snapshot.
# 5. Right-click the "Raw" button and copy to the clipboard.  That is the working snapshot URL for
#    that file.  Take off the filename, and you get the operative URL for this script.
#
# This file builds RUNALL.CMD, DOWNLOAD.CMD, and RUNMOST.CMD.


# UTF-8 output, no BOM; necessary for .CMD batch.
# Don't ask me why only ASCII registers as UTF-8 or I might scream.  Softly and miserably though.
$PSDefaultParameterValues['Out-File:Encoding'] = 'ASCII'

$githubURL = "https://raw.githubusercontent.com/jebofponderworthy/windows-tools/9904e67297606bc4f815d9655ea200e03e357e4f"

$RUNALLps1List = @(
	"RunDevNodeClean.ps1",
	"TweakNTFS.ps1",
	"OWTAS.ps1",
	"TOSC.ps1",
	"OVSS.ps1",
	"CATE.ps1"
	)

ForEach ($cmd in @('RUNALL.CMD', 'DOWNLOAD.CMD', 'RUNMOST.CMD')) {
	Remove-Item "..\RUN\$cmd" -Force -ErrorAction SilentlyContinue > $null
	New-Item -Name "..\RUN\$cmd" -ItemType File -Force > $null
	}
	
echo '@echo off' > ..\RUN\RUNALL.CMD
echo '' >> ..\RUN\RUNALL.CMD
echo '@echo off' > ..\RUN\DOWNLOAD.CMD
echo '' >> ..\RUN\DOWNLOAD.CMD
echo '@echo off' > ..\RUN\RUNMOST.CMD
echo '' >> ..\RUN\RUNMOST.CMD

$WebClientObj = (New-Object System.Net.WebClient)
$WebClientObj.Encoding = [System.Text.Encoding]::UTF8
	
ForEach ($ps1 in $RUNALLps1List) {

	echo "Processing $ps1 ..."
	
	$DownloadURL = "$githubURL/tools/$ps1"

	$WebClientObj.DownloadString($DownloadURL) > "..\tools\$ps1"
	
	# First get hash for the ps1 in study
	$ps1Hash = (certutil -hashfile "..\tools\$ps1" SHA256)[1] -replace '\s',''
	
	# First operative line in RUNALL.CMD, RUNMOST, and DOWNLOAD.CMD for this ps1 file
	$line1 = '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^' 
	# Second operative line.  Substitutions necessary, which means double quotes.  Singles within doubles are marked single, double within doubles marked double.
	$line2 = (	'"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString(''' +
				$DownloadURL + ''') > ' + $ps1 + '"' 	) 
				
	# Third.
	$line3 = '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^'
	# Fourth.  Substitutions necessary.  Within single-quoted strings, one embeds single quotes by doubling them.
	$line4 = (	 '"$certrpt = (certutil -hashfile ' +
				$ps1 + ' SHA256)[1] -replace ''\s'','''' ; If ($certrpt -eq ''' +
				$ps1Hash + ''') { iex .\' + $ps1 + ' } Else { ''Hash fail on ' + $ps1 + '!'' }"' 	)
				
	# Fifth.
	$line5 = "@del $ps1"

	echo 'echo:' >> ..\RUN\RUNALL.CMD
	echo "echo Downloading, verifying, and running $ps1 ..." >> ..\RUN\RUNALL.CMD
	echo 'echo ---' >> ..\RUN\RUNALL.CMD
	echo 'echo:' >> ..\RUN\RUNALL.CMD
	echo $line1 >> ..\RUN\RUNALL.CMD
	echo $line2 >> ..\RUN\RUNALL.CMD
	echo "" >> ..\RUN\RUNALL.CMD
	echo $line3 >> ..\RUN\RUNALL.CMD
	echo $line4 >> ..\RUN\RUNALL.CMD
	echo "" >> ..\RUN\RUNALL.CMD
	echo $line5 >> ..\RUN\RUNALL.CMD
	echo "" >> ..\RUN\RUNALL.CMD

	echo 'echo:' >> ..\RUN\DOWNLOAD.CMD
	echo "echo Downloading $ps1 ..." >> ..\RUN\DOWNLOAD.CMD
	echo 'echo ---' >> ..\RUN\DOWNLOAD.CMD
	echo 'echo:' >> ..\RUN\DOWNLOAD.CMD
	echo $line1 >> ..\RUN\DOWNLOAD.CMD
	echo $line2 >> ..\RUN\DOWNLOAD.CMD
	echo "" >> ..\RUN\DOWNLOAD.CMD
	
	if ($ps1 -ne 'TOSC.ps1') {
		echo 'echo:' >> ..\RUN\RUNMOST.CMD
		echo "echo Downloading, verifying, and running $ps1 ..." >> ..\RUN\RUNMOST.CMD
		echo 'echo ---' >> ..\RUN\RUNMOST.CMD
		echo 'echo:' >> ..\RUN\RUNMOST.CMD
		echo $line1 >> ..\RUN\RUNMOST.CMD
		echo $line2 >> ..\RUN\RUNMOST.CMD
		echo "" >> ..\RUN\RUNMOST.CMD
		echo $line3 >> ..\RUN\RUNMOST.CMD
		echo $line4 >> ..\RUN\RUNMOST.CMD
		echo "" >> ..\RUN\RUNMOST.CMD
		echo $line5 >> ..\RUN\RUNMOST.CMD
		echo "" >> ..\RUN\RUNMOST.CMD
		}
		
	Remove-Item $ps1 -ErrorAction SilentlyContinue > $null
		
    }


