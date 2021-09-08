$oldpower = powercfg -getactivescheme
$oldname = $oldpower[58..100] -join ""
$oldname = $oldname.Substring(0,$oldname.Length-1)
"Current power scheme name:  $oldname"
"Creating power scheme:  CPU Special"

$newpower = powercfg -duplicatescheme scheme_current
$newpower = ($newpower[19..54] -join "")
powercfg -changename $newpower "CPU Special"
powercfg -setactive $newpower

# Makes maximum CPU speeds available, by default they're not
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTMODE 0
powercfg -setacvalueindex scheme_current sub_processor PERFBOOSTMODE1 0
powercfg -setacvalueindex scheme_current sub_processor PERFINCTHRESHOLD 1
powercfg -setacvalueindex scheme_current sub_processor PERFINCTHRESHOLD1 1
powercfg -setacvalueindex scheme_current sub_processor PERFINCTIME 1
powercfg -setacvalueindex scheme_current sub_processor PERFINCTIME1 1
powercfg -setacvalueindex scheme_current sub_processor PERFDECTHRESHOLD 100
powercfg -setacvalueindex scheme_current sub_processor PERFDECTHRESHOLD1 100
powercfg -setacvalueindex scheme_current sub_processor LATENCYHINTPERF 0
powercfg -setacvalueindex scheme_current sub_processor LATENCYHINTPERF1 0
powercfg -setacvalueindex scheme_current sub_processor PERFAUTONOMOUS 0
powercfg -setacvalueindex scheme_current sub_processor PERFDUTYCYCLING 0

# Sets overall throttles to maximum
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX1 100
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100
powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN1 100
powercfg -setacvalueindex scheme_current sub_processor HETEROCLASS1INITIALPERF 100
powercfg -setacvalueindex scheme_current sub_processor HETEROCLASS0FLOORPERF 100

# Turns off CPU core controls, tells OS to just use them all.
powercfg -setacvalueindex scheme_current sub_processor CPMAXCORES 100
powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
powercfg -setacvalueindex scheme_current sub_processor DISTRIBUTEUTIL 0
powercfg -setacvalueindex scheme_current sub_processor CPDISTRIBUTION 1

# Minimizes CPU spinup time, and maximizes spindown time, just in case
powercfg -setacvalueindex scheme_current sub_processor CPINCREASETIME 1
powercfg -setacvalueindex scheme_current sub_processor CPDECREASETIME 100
powercfg -setacvalueindex scheme_current sub_processor CPHEADROOM 1
powercfg -setacvalueindex scheme_current sub_processor CPCONCURRENCY 1
powercfg -setacvalueindex scheme_current sub_processor LATENCYHINTUNPARK 1
powercfg -setacvalueindex scheme_current sub_processor LATENCYHINTUNPARK1 1

# Sets energy savings preference to zero
powercfg -setacvalueindex scheme_current sub_processor PERFEPP 0

# Commits all above changes to current power plan
powercfg -setactive scheme_current