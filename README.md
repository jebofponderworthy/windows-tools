# windows-tools

This is a toolset for improvement of performance of Windows desktop and server operating systems.  Much gratitude goes to Ponderworthy folks and friends for much input, a good bit of which can be read at [notes.ponderworthy.com](https://notes.ponderworthy.com).

PowerShell 3.0 and later are supported, on Windows 7/2008R2 and later; the exception is GetRedists, which requires 5.1.  Please note that 7 and 2008R2 ship with PowerShell 2.0 by default; installing the [WMF](https://www.microsoft.com/en-us/download/details.aspx?id=54616) will update it to 5.1.  

## RUNALL.CMD:  download, verify by hash, and run almost all of the tools

[RUNALL is a .CMD](https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/RUN/RUNALL.CMD) which, if run as administrator, will download, verify integrity by hash, and run RunDevNodeClean first, then wt_removeGhosts, then TweakNTFS, then OWTAS, then TOSC, then OVSS, and then CATE.  The result is a distinct performance hike on any current Windows machine.

Do not use this if you want Offline Files caching to be active, RUNMOST does everything except the Offline Files cache disabling.

For compatibility, hashing is done using the command-line CERTUTIL tool (capturing text output to PowerShell code run within CMD), instead of Get-FileHash.  SHA256 is in use.

## RUNMOST.CMD:  download, verify by hash, and run most of the tools

[RUNMOST is a .CMD](https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/RUN/RUN.CMD) which, if run as administrator, will download, verify integrity by hash, and run RunDevNodeClean, wt_removeGhosts, TweakNTFS, OWTAS, OVSS, and then CATE.  The result is a distinct performance hike on any current Windows machine.

*Do* use this if you want Offline Files caching to be active.  RUNMOST.CMD does not run TOSC.ps1.

For compatibility, hashing is done using the command-line CERTUTIL tool (capturing text output to PowerShell code run within CMD), instead of Get-FileHash.  SHA256 is in use.

## GETREDISTS.CMD:  Get and update Microsoft VC++ redistributables using GetRedists.ps1

Lots of software uses Microsoft VC++ redistributables.  They get updated fairly often and almost never automatically.  To bring all of yours up to date and install all the newers which Microsoft supports, run [GETREDISTS.CMD](https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/RUN/RUN.CMD) to call GetRedists.ps1.  Requires PowerShell 5.1, and automatically pulls in the VcRedist module.

## RunDevNodeClean

DevNodeClean is a Microsoft-provided utility which clears certain registry items, ones which are created when USB flash drives are plugged in and removed, when machines are virtualized or devirtualized, and many other operations.  These registry items pile up over time, we have seen some older Windows 7 desktops with hundreds of them, and they slow down Windows File Explorer and file management in general quite a bit.  [RunDevNodeClean](https://github.com/jebofponderworthy/windows-tools/raw/master/tools/RunDevNodeClean.ps1) downloads the utility from Microsoft, unpacks it, runs the appropriate (32-bit or 64-bit) binary, and then cleans up after itself.

## TweakNTFS: Tweak NTFS for Performance and Reliability

FSUTIL is a Windows command with amazing abilities.  In [TweakNTFS](https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/TweakNTFS.ps1) we have it used programmatically within PowerShell to produce a fairly well-balanced approach, performance increase with reliability increase too, for all NTFS volumes currently mounted.  

## CATE: (C)lean (A)ll system and user profile (T)emp folders, (E)tcetera

For quite a while I had been curious as to why a simple method to do this was not available. CCLEANER and others do not reach into every user profile, and on many machines this is crucial, e.g., terminal servers. CATE was originated as a .VBS by the excellent David Barrett ( http://www.cedit.biz ) and has been rewritten thoroughly by yours truly (JEB of Ponderworthy). The current VBS is [here.](https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/old-vbs/CATE.vbs)  But [the most recent version](https://raw.githubusercontent.com/jebofponderworthy/windows-tools/master/tools/CATE.ps1) is a PowerShell script, which adds removal of Ask Partner Network folders from user profiles, and a good bit of speed and clean running; future development will be in PowerShell.

One thing discovered along the way, is even in XP there was a user profile called the “System Profile” — XP had it in C:\WINDOWS\System32\config\systemprofile — and some malware dumps junk into it, and sometimes many gigs of unwanted files can be found in its temporary storage. CATE cleans all user profiles including those, as well as the Windows Error Reporting cache, and the system TEMP folders, and in recent versions, many Windows log files which are often found in many thousands of fragments.

The tool is designed for Windows 10 down through XP. It is self-elevating if run non-administratively.

## OWTAS: Optimize Service Work Items and Additional/Delayed Worker Threads

This tool sets a number of additional critical and delayed worker threads,
plus service work items. The changes are autocalculated according to a
combination of RAM and OS bit-width (32 vs. 64). Performance will increase,
more so with more RAM.

Documentation on these settings has ranged from sparse to none over
many years.  The early Microsoft documents used in the  calculations appear
completely gone, there are some new ones.  The settings produced by OWTAS
have undergone testing over the last ten years, on a wide variety of 
Wintelamd platforms, and appear to work well on all.
  
OWTAS is available as [VBS](https://github.com/jebofponderworthy/windows-tools/raw/master/old-vbs/OWTAS.VBS) and as [PowerShell](https://github.com/jebofponderworthy/windows-tools/raw/master/tools/OWTAS.ps1).  Future development will be in PowerShell.

The tool is designed for Windows 10 down through XP. As of 2017-10-10, it is self-elevating if run non-administratively.

## TOSC: Turn Off Share Caching

By default in Windows since XP/2003, if a folder is shared to the network via SMB, so-called "caching" is turned on.  This actually means that the Offline Files service on *other* machines accessing the share, are allowed to retrieve and store copies of files and folders on the machine acting as server.  Turning this off for all shares gives a speed bump for the server machine, and also improves reliability overall, dependence on Offline Files can lead to all sorts of issues including data loss when the server is not available or suddenly becomes available et cetera.  [TOSC](https://github.com/jebofponderworthy/windows-tools/raw/master/tools/TOSC.ps1) does this very well, for all file shares extant on the machine on which it is run.

## OVSS:  Optimize VSS

By default, on Windows client OS systems, VSS is active on all VSS-aware volumes, but it is not optimized, which in this case means, there is an "association" or preallocation, of zero space.  On Windows server OS systems, VSS is likewise active, but there is no association/preallocation, at all, on any VSS-aware volumes.  Many different (e.g., [StorageCraft](https://www.storagecraft.com/support/kb/article/289), [Carbonite](https://support.carbonite.com/articles/Server-Windows-How-to-Manage-VSS-Shadowstorage-Space), others) Windows tools make the same recommendation concerning this, stating that every volume to be backed up should have 20% of its space "associated" or preallocated for VSS.  [OVSS](https://github.com/jebofponderworthy/windows-tools/raw/master/tools/OVSS.ps1) does this, and also, removes all orphan shadows.  Orphan shadows are VSS snapshots existing uselessly because of old aborted backups, adding OS volume-related overhead.  The manual steps of this script, with one additional optional step very useful in some server configurations, [are documented here](https://notes.ponderworthy.com/thorough-cleanup-of-vss).

## wt_removeGhosts: remove ghost devices from Windows

Over time, Windows accumulates 'ghost devices', devices which can show up in Device Manager as transparent because they aren't actually there, but things are set up if they are plugged in again.  This applies to anything and everything, including motherboard device objects replaced during driver updates, VSS items, USB sticks inserted and removed, really anything at all.  This contributes greatly to slowdown of an old OS install image.  And removeGhosts removes them all.  This is not Ponderworthy code, but it's great stuff, found on several web sites.  No author cited within, but thanks are deserved!  
