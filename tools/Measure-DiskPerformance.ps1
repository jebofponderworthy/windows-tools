<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Version 1.2
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
Param( 
[parameter(mandatory=$False,HelpMessage='Name of test file')] 
[ValidateLength(2,30)] 
$TestFileName = "test.dat",

[parameter(mandatory=$False,HelpMessage='Test file size in GB')] 
[ValidateSet('1','5','10','50','100','500','1000')] 
$TestFileSizeInGB = 1,

[parameter(mandatory=$False,HelpMessage='Path to test folder')] 
[ValidateLength(3,254)] 
$TestFilepath = 'C:\Test',

[parameter(mandatory=$True,HelpMessage='Test mode, use Get-SmallIO for IOPS and Get-LargeIO for MB/s ')] 
[ValidateSet('Get-SmallIO','Get-LargeIO')] 
$TestMode,

[parameter(mandatory=$False,HelpMessage='Fast test mode or standard')] 
[ValidateSet('True','False')] 
$FastMode = 'True',

[parameter(mandatory=$False,HelpMessage='Remove existing test file')] 
[ValidateSet('True','False')] 
$RemoveTestFile='False',

[parameter(mandatory=$False,HelpMessage='Remove existing test file')] 
[ValidateSet('Out-GridView','Format-Table')] 
$OutputFormat='Out-GridView'
)
Function New-TestFile{
$Folder = New-Item -Path $TestFilePath -ItemType Directory -Force -ErrorAction SilentlyContinue
$TestFileAndPath = "$TestFilePath\$TestFileName"
Write-Host "Checking for $TestFileAndPath"
$FileExist = Test-Path $TestFileAndPath
if ($FileExist -eq $True)
{
    if ($RemoveTestFile -EQ 'True')
    {
        Remove-Item -Path $TestFileAndPath -Force
    }
    else
    {
        Write-Host 'File Exists, break'
        Break
    }
}
Write-Host 'Creating test file using fsutil.exe...'
& cmd.exe /c FSUTIL.EXE file createnew $TestFileAndPath ($TestFileSizeInGB*1024*1024*1024)
& cmd.exe /c FSUTIL.EXE file setvaliddata $TestFileAndPath ($TestFileSizeInGB*1024*1024*1024)
}
Function Remove-TestFile{
$TestFileAndPath = "$TestFilePath\$TestFileName"
Write-Host "Checking for $TestFileAndPath"
$FileExist = Test-Path $TestFileAndPath
if ($FileExist -eq $True)
{
    Write-Host 'File Exists, deleting'
    Remove-Item -Path $TestFileAndPath -Force -Verbose
}
}
Function Get-SmallIO{
Write-Host 'Initialize for SmallIO...'
8..64 | % {
    $KBytes = '8'
    $Type = 'random'
    $b = "-b$KBytes";
    $f = "-f$Type";
    $o = "-o $_";  
    $Result = & $RunningFromFolder\sqlio.exe $Duration -kR $f $b $o -t4 -LS -BN "$TestFilePath\$TestFileName"
    Start-Sleep -Seconds 5 -Verbose
    $iops = $Result.Split("`n")[10].Split(':')[1].Trim() 
    $mbs = $Result.Split("`n")[11].Split(':')[1].Trim() 
    $latency = $Result.Split("`n")[14].Split(':')[1].Trim()
    $SeqRnd = $Result.Split("`n")[14].Split(':')[1].Trim()
    New-object psobject -property @{
        Type = $($Type)
        SizeIOKBytes = $($KBytes)
        OutStandingIOs = $($_)
        IOPS = $($iops)
        MBSec = $($mbs)
        LatencyMS = $($latency)
        Target = $("$TestFilePath\$TestFileName")
        }
    }
}
Function Get-LargeIO{
$KBytes = '512'
$Type = 'sequential'
Write-Host 'Initialize for LargeIO...'
Write-Host "Reading $KBytes Bytes in $Type mode using $TestFilePath\$TestFileName as target"
1..32 | % {
    $b = "-b$KBytes";
    $f = "-f$Type";
    $o = "-o $_";  
    $Result = & $RunningFromFolder\sqlio.exe $Duration -kR $f $b $o -t1 -LS -BN "$TestFilePath\$TestFileName"
    Start-Sleep -Seconds 5 -Verbose
    $iops = $Result.Split("`n")[10].Split(':')[1].Trim() 
    $mbs = $Result.Split("`n")[11].Split(':')[1].Trim() 
    $latency = $Result.Split("`n")[14].Split(':')[1].Trim()
    $SeqRnd = $Result.Split("`n")[14].Split(':')[1].Trim()
    New-object psobject -property @{
        Type = $($Type)
        SizeIOKBytes = $($KBytes)
        OutStandingIOs = $($_)
        IOPS = $($iops)
        MBSec = $($mbs)
        LatencyMS = $($latency)
        Target = $("$TestFilePath\$TestFileName")
        }
    }
}

#Checking for fast mode
if ($FastMode -lt $True){$Duration = '-s60'}else{$Duration = '-s10'}

#Setting script location to find the exe's
$RunningFromFolder = $MyInvocation.MyCommand.Path | Split-Path -Parent 
Write-Host “Running this from $RunningFromFolder”

#Main
. New-TestFile
switch ($OutputFormat){
    'Out-GridView' {
    . $TestMode | Select-Object MBSec,IOPS,SizeIOKBytes,LatencyMS,OutStandingIOs,Type,Target | Out-GridView
    }
    'Format-Table' {
    . $TestMode | Select-Object MBSec,IOPS,SizeIOKBytes,LatencyMS,OutStandingIOs,Type,Target | Format-Table
    }
    Default {}
}
. Remove-TestFile

