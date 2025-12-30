# ConOps Reports — Folder Generator ✅

This repository contains a PowerShell script to generate report folder structures for a given year following this convention:

- Daily: `Daily\<Year>\<MonthName>\<MMDDYY>`  (example: `Daily\2026\December\122425`)
- Weekly: `Weekly\<Year>\<MonthName>\<startMMDD-endMMDD>`  (example: `Weekly\2026\December\1215-1219`)
  - Weeks are Mon–Fri. Weeks that start in the prior year or extend into the next year are included for the target year; the folder is placed under the start-date's month inside the target `Weekly\<Year>` folder.
- Monthly: `Monthly\<Year>\<MonthName>`  (example: `Monthly\2026\December`)
- Quarterly: `Quarterly\<Year>\Q1..Q4`  (example: `Quarterly\2026\Q4`)

## Usage 🔧

Run in PowerShell Core (pwsh):

Dry run (prints what would be created):

```powershell
pwsh ./scripts/generate-report-folders.ps1 -Year 2026 -RootPath "./ConOpsReports" -DryRun
```

Create folders:

```powershell
pwsh ./scripts/generate-report-folders.ps1 -Year 2026 -RootPath "./ConOpsReports"
```

## Notes 💡
- Default year is `2026`.
- Script is cross-platform (PowerShell Core / pwsh).
- Weekly ranges are computed with Monday as the start and Friday as the end; the folder is placed under the start-date's month.

If you'd like me to change week rules (e.g., Sunday–Thursday, or include weeks that start in prior year), tell me and I will update the script.
