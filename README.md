# ponderworthy-tools

Some applets for Windows, courtesy of Ponderworthy folks and friends.  Original site is https://notes.ponderworthy.com.
All PowerShell applets require version 2.0 (Windows 7 default) or later.

## RUNALL.CMD:  Download, verify by hash, and run all of the below

[This is a CMD](https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/RUNALL.CMD), which if run as administrator, will download, verify integrity by hash, and run both of the below.  It runs OWTAS first and then CATE, for a bit of a speed increment.  

This requires PowerShell to be present, though runs in administrative CMD.  Hashing is done using the command-line CERTUTIL tool (capturing text output to PowerShell code run within CMD), instead of Get-FileHash, for compatibility.

## CATE: (C)lean (A)ll system and user profile (T)emp folders, (E)tcetera

For quite a while I had been curious as to why a simple method to do this was not available. CCLEANER and others do not reach into every user profile, and on many machines this is crucial, e.g., terminal servers. CATE was originated as a .VBS by the excellent David Barrett ( http://www.cedit.biz ) and has been rewritten thoroughly by yours truly (JEB of Ponderworthy). The current VBS is [here.](https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/CATE.vbs)  But [the most recent version](https://raw.githubusercontent.com/jebofponderworthy/ponderworthy-tools/master/CATE.ps1) is a PowerShell script, which adds removal of Ask Partner Network folders from user profiles, and a good bit of speed and clean running; future development will be in PowerShell.

One thing discovered along the way, is even in XP there was a user profile called the “System Profile” — XP had it in C:\WINDOWS\System32\config\systemprofile — and some malware dumps junk into it, and sometimes many gigs of unwanted files can be found in its temporary storage. CATE cleans all user profiles including those, as well as the Windows Error Reporting cache, and the .NET caches, and the system TEMP folders, and in recent versions, many Windows log files which are often found in many thousands of fragments.

The tool is designed for Windows 10 down through XP. As of 2017-10-10, it is self-elevating if run non-administratively.

## OWTAS: Optimize Service Work Items and Additional/Delayed Worker Threads

This tool sets a number of additional critical and delayed worker threads, plus service work items. The changes are autocalculated according to a combination of RAM and OS bit-width (32 vs. 64). Performance will increase, more so with more RAM.  Available as [VBS](https://github.com/jebofponderworthy/ponderworthy-tools/raw/master/OWTAS.VBS) and as [PowerShell](https://github.com/jebofponderworthy/ponderworthy-tools/raw/master/OWTAS.ps1).  Future development will be in PowerShell.

The tool is designed for Windows 10 down through XP. As of 2017-10-10, it is self-elevating if run non-administratively.

