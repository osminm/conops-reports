<#
.SYNOPSIS
Generate folder structures for Daily, Weekly, Monthly, and Quarterly reports for a given year.

.PARAMETER Year
Target year to generate folders for (default 2026).

.PARAMETER RootPath
Root directory under which to create the report folders (default: current directory).

.PARAMETER DryRun
If specified, print the directories that would be created instead of actually creating them.

.NOTES
- Weekly folders are Monday–Friday ranges and are placed under the start date's month.
- Daily naming: MMDDYY (e.g., 010126 for Jan 1, 2026)
- Weekly naming: startMMDD-endMMDD (e.g., 1215-1219)
- Monthly naming: Month name (e.g., December)
- Quarterly naming: Q1..Q4
#>
param(
    [int]$Year = 2026,
    [string]$RootPath = ".",
    [switch]$DryRun
)

function Write-Action {
    param($Path)
    if ($DryRun) { Write-Output "DRYRUN: $Path" } else { New-Item -ItemType Directory -Path $Path -Force | Out-Null; Write-Output "Created: $Path" }
}

# Use invariant culture to ensure English month names
$culture = [System.Globalization.CultureInfo]::InvariantCulture

# Resolve root path
$root = (Resolve-Path -Path $RootPath -ErrorAction SilentlyContinue)
if (-not $root) { $rootPathResolved = (New-Item -ItemType Directory -Path $RootPath -Force).FullName } else { $rootPathResolved = $root.Path }

# Base folders
$dailyBase = Join-Path $rootPathResolved (Join-Path "Daily" $Year)
$weeklyBase = Join-Path $rootPathResolved (Join-Path "Weekly" $Year)
$monthlyBase = Join-Path $rootPathResolved (Join-Path "Monthly" $Year)
$quarterlyBase = Join-Path $rootPathResolved (Join-Path "Quarterly" $Year)

# Create Quarterly (Q1..Q4)
for ($q = 1; $q -le 4; $q++) {
    $qPath = Join-Path $quarterlyBase "Q$q"
    Write-Action $qPath
}

# Create Monthly and Daily
for ($m = 1; $m -le 12; $m++) {
    $monthName = $culture.DateTimeFormat.GetMonthName($m)
    $monthlyMonthPath = Join-Path $monthlyBase $monthName
    Write-Action $monthlyMonthPath

    $dailyMonthPath = Join-Path $dailyBase $monthName
    Write-Action $dailyMonthPath

    # For each day in the month
    $dt = Get-Date -Year $Year -Month $m -Day 1
    while ($dt.Month -eq $m -and $dt.Year -eq $Year) {
        $dayName = $dt.ToString("MMddyy")
        $dayPath = Join-Path $dailyMonthPath $dayName
        Write-Action $dayPath
        $dt = $dt.AddDays(1)
    }
}

# Create Weekly (Monday-Friday), weeks placed in the start date's month
# Find the Monday on or before Jan 1 of the specified year so that
# weeks that start in the prior year but overlap the target year are included.
$startDate = Get-Date -Year $Year -Month 1 -Day 1
while ($startDate.DayOfWeek -ne [System.DayOfWeek]::Monday) { $startDate = $startDate.AddDays(-1) }

# Include Mondays from $startDate up to and including the last Monday on or before Dec 31
$endDate = Get-Date -Year $Year -Month 12 -Day 31

$dt = $startDate
while ($dt -le $endDate) {
    $weekStart = $dt
    $weekEnd = $dt.AddDays(4)  # Monday - Friday

    # Determine folder naming and placement month (start date's month)
    $monthName = $culture.DateTimeFormat.GetMonthName($weekStart.Month)
    $weekName = "{0}-{1}" -f $weekStart.ToString('MMdd'), $weekEnd.ToString('MMdd')
    $weekFolder = Join-Path (Join-Path $weeklyBase $monthName) $weekName
    Write-Action $weekFolder

    $dt = $dt.AddDays(7)
}

Write-Output "\nDone."
Write-Output "Year: $Year; Root: $rootPathResolved; DryRun: $($DryRun.IsPresent)" 