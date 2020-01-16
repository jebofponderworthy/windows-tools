#######################################################################
# RunCleanMgr											              #
# v1.2                                                                #
#######################################################################

#
# Configure and run code mostly copied from MT-FreeHongKong and/or Orlando, and Nathan Hartley, 
# as posted to "Stack Overflow":
# https://stackoverflow.com/questions/28852786/automate-process-of-disk-cleanup-cleanmgr-exe-without-user-intervention
# https://stackoverflow.com/questions/28852786/automate-process-of-disk-cleanup-cleanmgr-exe-without-user-intervention#35214197
#

$WinVersionStr = Get-CimInstance -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption

if ($WinVersionStr -Like "* Server 2012R2 *")
{
	"Server 2012R2.  Exiting."
	""
	exit 0
}

"Setting CleanMgr run parameters..."

$VolumeCachesRegDir = "hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$CacheDirItemNames = Get-ItemProperty "$VolumeCachesRegDir\*" | select -ExpandProperty PSChildName

$CacheDirItemNames | 
    %{
        $exists = Get-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name "StateFlags6553" -ErrorAction SilentlyContinue
        If (($exists -ne $null) -and ($exists.Length -ne 0))
            {
                Set-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name StateFlags6553 -Value 2  | Out-Null
            }
        else
            {
                New-ItemProperty -Path "$VolumeCachesRegDir\$_" -Name StateFlags6553 -Value 0 -PropertyType DWord  | Out-Null
            }
     }
Start-Sleep -Seconds 3

"Running CleanMgr.exe..."

Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:65535' -WindowStyle Hidden -PassThru

"Waiting for CleanMgr and DismHost processes. Necesary as CleanMgr.exe spins off separate processes."

Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process
