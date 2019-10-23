
<#PSScriptInfo

.VERSION 1.14

.GUID 2f1b0fa1-c184-47e6-b65c-8ed5c92db371

.AUTHOR Jonathan E. Brickman

.COMPANYNAME Ponderworthy Music

.COPYRIGHT (c) 2018 Jonathan E. Brickman

.TAGS 

.LICENSEURI https://opensource.org/licenses/BSD-3-Clause

.PROJECTURI https://github.com/jebofponderworthy/windows-tools

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
RunDevNodeClean
Downloads the DevNodeClean package, chooses the binary appropriate to
the bit-width of the current OS, and runs it.  This cleans unused
device nodes in the registry, improving performance.

.PRIVATEDATA 

#> 













<#

.DESCRIPTION 
RunDevNodeClean - cleans unused device nodes in registry, improves performance

#>

Param()


###################################
#  Download and Run DevNodeClean  #
###################################

#
# by Jonathan E. Brickman
#
# Downloads the DevNodeClean package, chooses the binary
# appropriate to the bit-width of the current OS, and runs it.
# This cleans unused device nodes in the registry,
# improving performance
#
# Copyright 2018 Jonathan E. Brickman
# https://notes.ponderworthy.com/
# This script is licensed under the 3-Clause BSD License
# https://opensource.org/licenses/BSD-3-Clause
# and is reprised at the end of this file
#

""
""
"*********************"
"   RunDevNodeClean   "
"*********************"
""
""

$StartupDir = $pwd

# First, set up temporary space and move there.

"Setting up..."

$TempFolderName = -join ((65..90) + (97..122) | Get-Random -Count 10 | ForEach-Object {[char]$_})

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

# Runs it twice, for some reason the first run
# often misses some.

if ([System.IntPtr]::Size -eq 4) {
    # 32-bit OS
	"Running 32-bit binary..."
	""
	Invoke-Expression $TempPath\x86\DevNodeClean.exe
	Invoke-Expression $TempPath\x86\DevNodeClean.exe
	} else {
	# 64-bit OS
	"Running 64-bit binary..."
	""
	Invoke-Expression $TempPath\x64\DevNodeClean.exe
	Invoke-Expression $TempPath\x64\DevNodeClean.exe
	}

""

# Clean up.

"Cleaning up..."

Set-Location $StartupDir
Remove-Item -Path $TempPath -Force -Recurse -ErrorAction SilentlyContinue

"Done!"

# The 3-Clause BSD License

# SPDX short identifier: BSD-3-Clause

# Note: This license has also been called
# the "New BSD License" or "Modified BSD License".
# See also the 2-clause BSD License.

# Copyright 2017 Jonathan E. Brickman

# Redistribution and use in source and binary
# forms, with or without modification, are
# permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the
# above copyright notice, this list of conditions and
# the following disclaimer.

# 2. Redistributions in binary form must reproduce the
# above copyright notice, this list of conditions and
# the following disclaimer in the documentation and/or
# other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the
# names of its contributors may be used to endorse or
# promote products derived from this software without
# specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.






















