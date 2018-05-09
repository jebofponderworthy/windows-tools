###########################################################################################################
#
# Run-script autobuilder 
#
##############################
#
# This script requires PowerShell 5.1 or higher.  
# Its result is a CMD, which needs to call PowerShell 3.0 or higher.
#
# Github stores its files in treelevels, per history.  For instance this:
# 
# https://github.com/jebofponderworthy/ponderworthy-tools/tree/c4191d3d005d09dfe07e3139bc03a6dc8c047973
#
# brings up the whole repository, all files, as they existed at a certain time, April 6, 2018.  Such
# a URL can be had from any file page in the repository.
#
# As a result, we use much of that URL to pull down all .ps1 files for the building, 
# if the April 6 version of the whole is what we want to use.  Then we build RUNALL.CMD
# and RUNMOST.CMD, including building hashes for them.
#
# This file builds sets like this:
#
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
# "(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/4a4e844b1aed1bcadc904c6ecd5a38fa25f6d667/TweakNTFS.ps1') > TweakNTFS.ps1"
#
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
# "$certrpt = (certutil -hashfile TweakNTFS.ps1 SHA256)[1] -replace '\s','' ; If ($certrpt -eq 'ae61337d69ebc8ed4666962c4d65574efb47df794b667a99c8d76bb7474deaa0') { iex .\TweakNTFS.ps1 } Else { 'Hash fail on TweakNTFS!' }"

# @del TweakNTFS.ps1

# UTF-8 output, no BOM; necessary for .CMD batch.
$PSDefaultParameterValues['Out-File:Encoding'] = 'ASCII'

$githubURL = "https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/b14e595eae970db5a5f4b21ad4e26b46665bbeb9/"

$RUNALLps1List = @(
	"RunDevNodeClean.ps1",
    "TweakNTFS.ps1",
    "OWTAS.ps1",
    "TOSC.ps1",
    "OVSS.ps1",
    "CATE.ps1"
    )

ForEach ($cmd in @('RUNALL.CMD', 'DOWNLOAD.CMD', 'RUNMOST.CMD')) {
	Remove-Item ".\$cmd" -Force > $null
	New-Item -Name $cmd -ItemType File -Force > $null
	}

$WebClientObj = (New-Object System.Net.WebClient)
$WebClientObj.Encoding = [System.Text.Encoding]::UTF8
	
ForEach ($ps1 in $RUNALLps1List) {

	echo "Processing $ps1 ..."
	
	$DownloadURL = "$githubURL$ps1"

	$WebClientObj.DownloadString("$githubURL$ps1") > $ps1
	
	# First get hash for the ps1 in study
	$ps1Hash = (certutil -hashfile $ps1 SHA256)[1] -replace '\s',''
	
	# First operative line in RUNALL.CMD, RUNMOST, and DOWNLOAD.CMD for this ps1 file
	$line1 = '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^' 
	# Second operative line.  Substitutions necessary, which means double quotes.  Singles within doubles are marked single, double within doubles marked double.
	$line2 = (	'"$wco = (New-Object System.Net.WebClient); $wco.Encoding = [System.Text.Encoding]::UTF8; $wco.DownloadString(''' +
				$githubURL + $ps1 + ''') > ' + $ps1 + '"' 	) 
				
	# Third.
	$line3 = '@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^'
	# Fourth.  Substitutions necessary.  Within single-quoted strings, one embeds single quotes by doubling them.
	$line4 = (	 '"$certrpt = (certutil -hashfile ' +
				$ps1 + ' SHA256)[1] -replace ''\s'','''' ; If ($certrpt -eq ''' +
				$ps1Hash + ''') { iex .\' + $ps1 + ' } Else { ''Hash fail on ' + $ps1 + '!'' }"' 	)
				
	# Fifth.
	$line5 = "@del $ps1"

	
	echo $line1 >> RUNALL.CMD
	echo $line2 >> RUNALL.CMD
	echo "" >> RUNALL.CMD
	echo $line3 >> RUNALL.CMD
	echo $line4 >> RUNALL.CMD
	echo "" >> RUNALL.CMD
	echo $line5 >> RUNALL.CMD
	echo "" >> RUNALL.CMD

	echo $line1 >> DOWNLOAD.CMD
	echo $line2 >> DOWNLOAD.CMD
	echo "" >> DOWNLOAD.CMD
	
	if ($ps1 -ne 'TOSC.ps1') {
		echo $line1 >> RUNMOST.CMD
		echo $line2 >> RUNMOST.CMD
		echo "" >> RUNMOST.CMD
		echo $line3 >> RUNMOST.CMD
		echo $line4 >> RUNMOST.CMD
		echo "" >> RUNMOST.CMD
		echo $line5 >> RUNMOST.CMD
		echo "" >> RUNMOST.CMD
		}
		
    }


