###################################
#  Download and Run DevNodeClean  #
#               1.0               #

$StartupDir = $pwd

# First, set up temporary space and move there.

"Setting up..."

$TempFolderName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})

$envTEMP = [Environment]::GetEnvironmentVariable("TEMP")
$TempPath = "$envTEMP\$TempFolderName"
mkdir $TempPath > $null

# Then download the zip file.

"Downloading the binary from Microsoft..."

$WebClientObj = (New-Object System.Net.WebClient)
$WebClientObj.DownloadFile("https://download.microsoft.com/download/B/C/6/BC670519-7EA1-44BE-8B5C-6FF83A7FF96C/devnodeclean.zip","$TempPath\devnodeclean.zip") > $null

# Now unpack the zip file.

"Unpacking..."

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip {
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath) > $null
	}

Unzip "$TempPath\devnodeclean.zip" "$TempPath"

# Now get the bit-width of the operating system, and
# run the appropriate binary.

if ([System.IntPtr]::Size -eq 4) { 
    # 32-bit OS
	"Running 32-bit binary..."
	""
	iex $TempPath\x86\DevNodeClean.exe
	} else {
	# 64-bit OS
	"Running 64-bit binary..."
	""
	iex $TempPath\x64\DevNodeClean.exe
	}
	
""
	
# Clean up.

"Cleaning up..."

cd $StartupDir
Remove-Item -Path $TempPath -Force -Recurse -ErrorAction SilentlyContinue

"Done!"



