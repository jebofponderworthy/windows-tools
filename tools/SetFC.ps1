########################################
#     SetFC: Set Windows File Cache    #
# for better overall memory management #
########################################

#
# Copied from a post by "BeowulfNode42" on Server Fault,
# no further personal/ID/copyright info made available by her/him
#
# Helps any machine run better when its RAM
# is pushed heavily, by keeping tighter control
# of disk file caching.  Also eliminates a known
# related issue in some versions of Windows.
#
# For permanence, this does have to run at each boot.
#

# Filename: setfc.ps1
$version = 1.1

#########################
# Settings
#########################

# The percentage of physical ram that will be used for SetSystemFileCache Maximum
$MaxPercent = 12.5

#########################
# Init multipliers
#########################
$OSBits = ([System.IntPtr]::Size) * 8
switch ( $OSBits)
{
    32 { $KiB = [int]1024 }
    64 { $KiB = [long]1024 }
    default {
        # not 32 or 64 bit OS. what are you doing??
        $KiB = 1024 # and hope it works anyway
        write-output "You have a weird OS which is $OSBits bit. Having a go anyway."
    }
}
# These values "inherit" the data type from $KiB
$MiB = 1024 * $KiB
$GiB = 1024 * $MiB
$TiB = 1024 * $GiB
$PiB = 1024 * $TiB
$EiB = 1024 * $PiB


#########################
# Calculated Settings
#########################

# Note that because we are using signed integers instead of unsigned
# these values are "limited" to 2 GiB or 8 EiB for 32/64 bit OSes respectively

$PhysicalRam = 0
$PhysicalRam = [long](invoke-expression (((get-wmiobject -class "win32_physicalmemory").Capacity) -join '+'))
if ( -not $? ) {
    write-output "Trying another method of detecting amount of installed RAM."
 }
if ($PhysicalRam -eq 0) {
    $PhysicalRam = [long]((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory) # gives value a bit less than actual
}
if ($PhysicalRam -eq 0) {
    write-error "Cannot Detect Physical Ram Installed. Assuming 4 GiB."
    $PhysicalRam = 4 * $GiB
}
$NewMax = [long]($PhysicalRam * 0.01 * $MaxPercent)
# The default value
# $NewMax = 1 * $TiB


#########################
# constants
#########################

# Flags bits
$FILE_CACHE_MAX_HARD_ENABLE     = 1
$FILE_CACHE_MAX_HARD_DISABLE    = 2
$FILE_CACHE_MIN_HARD_ENABLE     = 4
$FILE_CACHE_MIN_HARD_DISABLE    = 8


################################
# C# code
# for interface to kernel32.dll
################################
$source = @"
using System;
using System.Runtime.InteropServices;

namespace MyTools
{
    public static class cache
    {
        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool GetSystemFileCacheSize(
            ref IntPtr lpMinimumFileCacheSize,
            ref IntPtr lpMaximumFileCacheSize,
            ref IntPtr lpFlags
            );

        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool SetSystemFileCacheSize(
          IntPtr MinimumFileCacheSize,
          IntPtr MaximumFileCacheSize,
          Int32 Flags
        );

        [DllImport("kernel32", CharSet = CharSet.Unicode)]
        public static extern int GetLastError();

        public static bool Get( ref IntPtr a, ref IntPtr c, ref IntPtr d )
        {
            IntPtr lpMinimumFileCacheSize = IntPtr.Zero;
            IntPtr lpMaximumFileCacheSize = IntPtr.Zero;
            IntPtr lpFlags = IntPtr.Zero;

            bool b = GetSystemFileCacheSize(ref lpMinimumFileCacheSize, ref lpMaximumFileCacheSize, ref lpFlags);

            a = lpMinimumFileCacheSize;
            c = lpMaximumFileCacheSize;
            d = lpFlags;
            return b;
        }


        public static bool Set( IntPtr MinimumFileCacheSize, IntPtr MaximumFileCacheSize, Int32 Flags )
        {
            bool b = SetSystemFileCacheSize( MinimumFileCacheSize, MaximumFileCacheSize, Flags );
            if ( !b ) {
                Console.Write("SetSystemFileCacheSize returned Error with GetLastError = ");
                Console.WriteLine( GetLastError() );
            }
            return b;
        }
    }

    public class AdjPriv
    {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);

        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);

        [DllImport("advapi32.dll", SetLastError = true)]
        internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        internal struct TokPriv1Luid
        {
            public int Count;
            public long Luid;
            public int Attr;
        }
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

        public static bool EnablePrivilege(long processHandle, string privilege, bool disable)
        {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = new IntPtr(processHandle);
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            if(disable)
            {
                tp.Attr = SE_PRIVILEGE_DISABLED;
            } else {
                tp.Attr = SE_PRIVILEGE_ENABLED;
            }
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        }
    }
}
"@
# Add the c# code to the powershell type definitions
Add-Type -TypeDefinition $source -Language CSharp

#########################
# Powershell Functions
#########################
function output-flags ($flags)
{
    Write-output ("FILE_CACHE_MAX_HARD_ENABLE  : " + (($flags -band $FILE_CACHE_MAX_HARD_ENABLE) -gt 0) )
    Write-output ("FILE_CACHE_MAX_HARD_DISABLE : " + (($flags -band $FILE_CACHE_MAX_HARD_DISABLE) -gt 0) )
    Write-output ("FILE_CACHE_MIN_HARD_ENABLE  : " + (($flags -band $FILE_CACHE_MIN_HARD_ENABLE) -gt 0) )
    Write-output ("FILE_CACHE_MIN_HARD_DISABLE : " + (($flags -band $FILE_CACHE_MIN_HARD_DISABLE) -gt 0) )
    write-output ""
}

#########################
# Main program
#########################

write-output ""

#########################
# Get and set privilege info
$ProcessId = $pid
$processHandle = (Get-Process -id $ProcessId).Handle
$Privilege = "SeIncreaseQuotaPrivilege"
$Disable = $false
Write-output ("Enabling SE_INCREASE_QUOTA_NAME status: " + [MyTools.AdjPriv]::EnablePrivilege($processHandle, $Privilege, $Disable) )

write-output ("Program has elevated privledges: " + ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") )
write-output ""
whoami /PRIV | findstr /I "SeIncreaseQuotaPrivilege" | findstr /I "Enabled"
if ( -not $? )  {
    write-error "user Security Token SE_INCREASE_QUOTA_NAME: Disabled`r`n"
}
write-output "`r`n"


#########################
# Get Current Settings
# Init variables
$SFCMin = 0
$SFCMax = 0
$SFCFlags = 0
#Get Current values from kernel
$status = [MyTools.cache]::Get( [ref]$SFCMin, [ref]$SFCMax, [ref]$SFCFlags )
#typecast values so we can do some math with them
$SFCMin = [long]$SFCMin
$SFCMax = [long]$SFCMax
$SFCFlags = [long]$SFCFlags
write-output "Return values from GetSystemFileCacheSize are: "
write-output "Function Result : $status"
write-output "            Min : $SFCMin"
write-output ("            Max : $SFCMax ( " + $SFCMax / 1024 / 1024 / 1024 + " GiB )")
write-output "          Flags : $SFCFlags"
output-flags $SFCFlags


#########################
# Output our intentions
write-output ("Physical Memory Detected : $PhysicalRam ( " + $PhysicalRam / $GiB + " GiB )")
write-output ("Setting Max to " + $MaxPercent + "% : $NewMax ( " + $NewMax / $MiB + " MiB )`r`n")

#########################
# Set new settings
$SFCFlags = $SFCFlags -bor $FILE_CACHE_MAX_HARD_ENABLE # set max enabled
$SFCFlags = $SFCFlags -band (-bnot $FILE_CACHE_MAX_HARD_DISABLE) # unset max dissabled if set
# or if you want to override this calculated value
# $SFCFlags = 0
$status = [MyTools.cache]::Set( $SFCMin, $NewMax, $SFCFlags ) # calls the c# routine that makes the kernel API call
write-output "Set function returned: $status`r`n"
# if it was successfull the new SystemFileCache maximum will be NewMax
if ( $status ) {
    $SFCMax = $NewMax
}


#########################
# After setting the new values, get them back from the system to confirm
# Re-Init variables
$SFCMin = 0
$SFCMax = 0
$SFCFlags = 0
#Get Current values from kernel
$status = [MyTools.cache]::Get( [ref]$SFCMin, [ref]$SFCMax, [ref]$SFCFlags )
#typecast values so we can do some math with them
$SFCMin = [long]$SFCMin
$SFCMax = [long]$SFCMax
$SFCFlags = [long]$SFCFlags
write-output "Return values from GetSystemFileCacheSize are: "
write-output "Function Result : $status"
write-output "            Min : $SFCMin"
write-output ("            Max : $SFCMax ( " + $SFCMax / 1024 / 1024 / 1024 + " GiB )")
write-output "          Flags : $SFCFlags"
output-flags $SFCFlags
