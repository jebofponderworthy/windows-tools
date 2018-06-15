$ReleaseNotes = @(
	"OWTAS",
	"This tool sets a number of additional critical and delayed worker threads,",
	"plus service work items. The changes are autocalculated according to a",
	"combination of RAM and OS bit-width (32 vs. 64). Performance will increase,",
	"more so with more RAM.",
	"",
	"Documentation on these settings has ranged from sparse to none over many years. ",
	"The early Microsoft documents used in the calculations appear completely gone,",
	"there are some new ones. The settings produced by OWTAS have undergone testing",
	"over the last ten years, on a wide variety of Wintelamd platforms, and appear ",
	"to work well on all."
	)

Update-ScriptFileInfo -Path .\OWTAS.ps1 -Version 3.01 `
	-Author "Jonathan E. Brickman" `
	-Description "OVSS - optimizes VSS preallocation to 20% for each NTFS volume, and clears orphan shadows" `
	-ReleaseNotes $ReleaseNotes `
	-CompanyName "Ponderworthy Music" `
	-Copyright "(c) 2018 Jonathan E. Brickman" `
	-Force

Publish-Script -Path .\OWTAS.ps1 -NuGetApiKey ff4b1024-6264-4e77-b672-88c5ebe0c10d
