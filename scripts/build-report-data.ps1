param([string]$DataFile = (Join-Path $PSScriptRoot "..\data\batting.csv"))

$ErrorActionPreference = "Stop"
$rows = Import-Csv $DataFile
$num = { param($value) if ($value -eq "") { 0 } else { [double]$value } }

function Sum-Field($items, $field) {
    return [double](($items | Measure-Object -Property $field -Sum).Sum)
}

function Rate($numerator, $denominator, $digits = 3) {
    if ($denominator -eq 0) { return 0 }
    return [math]::Round($numerator / $denominator, $digits)
}

$career = $rows | Group-Object playerID | ForEach-Object {
    $g = $_.Group
    $ab = Sum-Field $g atBats
    $h = Sum-Field $g hits
    [PSCustomObject]@{
        playerID = $_.Name
        playerName = $g[0].playerName
        atBats = [int]$ab
        hits = [int]$h
        homeRuns = [int](Sum-Field $g homeRuns)
        stolenBases = [int](Sum-Field $g stolenBases)
        battingAverage = Rate $h $ab 3
    }
}

$byYear = $rows | Group-Object year | ForEach-Object {
    $g = $_.Group
    $ab = Sum-Field $g atBats
    $h = Sum-Field $g hits
    $hr = Sum-Field $g homeRuns
    $so = Sum-Field $g strikeouts
    $bb = Sum-Field $g walks
    [PSCustomObject]@{
        year = [int]$_.Name
        atBats = [int]$ab
        hits = [int]$h
        homeRuns = [int]$hr
        stolenBases = [int](Sum-Field $g stolenBases)
        triples = [int](Sum-Field $g triples)
        strikeouts = [int]$so
        walks = [int]$bb
        battingAverage = Rate $h $ab 3
        hrPer100Ab = Rate (100 * $hr) $ab 2
        strikeoutsPer100Ab = Rate (100 * $so) $ab 2
        walksPer100Ab = Rate (100 * $bb) $ab 2
    }
} | Sort-Object year

$byDecade = $rows | Group-Object { [math]::Floor(([int]$_.year) / 10) * 10 } | ForEach-Object {
    $g = $_.Group
    $ab = Sum-Field $g atBats
    $h = Sum-Field $g hits
    $hr = Sum-Field $g homeRuns
    $so = Sum-Field $g strikeouts
    $bb = Sum-Field $g walks
    [PSCustomObject]@{
        decade = "$($_.Name)s"
        atBats = [int]$ab
        homeRunsPer100Ab = Rate (100 * $hr) $ab 2
        strikeoutsPer100Ab = Rate (100 * $so) $ab 2
        walksPer100Ab = Rate (100 * $bb) $ab 2
        battingAverage = Rate $h $ab 3
        stolenBasesPer100Games = Rate (100 * (Sum-Field $g stolenBases)) (Sum-Field $g games) 2
        triplesPer100Ab = Rate (100 * (Sum-Field $g triples)) $ab 2
    }
} | Sort-Object decade

$teamSeasons = $rows | Group-Object year, teamID | ForEach-Object {
    $g = $_.Group
    [PSCustomObject]@{
        year = [int]$g[0].year
        teamID = $g[0].teamID
        teamName = $g[0].teamName
        homeRuns = [int](Sum-Field $g homeRuns)
        stolenBases = [int](Sum-Field $g stolenBases)
        runs = [int](Sum-Field $g runs)
    }
}

$report = [ordered]@{
    headline = [ordered]@{
        rows = $rows.Count
        seasons = ($rows.year | Sort-Object -Unique).Count
        players = ($rows.playerID | Sort-Object -Unique).Count
        homeRuns = [int](Sum-Field $rows homeRuns)
    }
    yearlyRates = @($byYear | Where-Object year -ge 1901)
    decadeRates = @($byDecade | Where-Object { [int]($_.decade.TrimEnd('s')) -ge 1900 -and [int]($_.decade.TrimEnd('s')) -lt 2020 })
    homeRunSeasons = @($byYear | Sort-Object homeRuns -Descending | Select-Object -First 10 year, homeRuns, hrPer100Ab)
    careerHomeRuns = @($career | Sort-Object homeRuns -Descending | Select-Object -First 10 playerName, homeRuns)
    careerAverage = @($career | Where-Object atBats -ge 3000 | Sort-Object battingAverage -Descending | Select-Object -First 10 playerName, battingAverage, hits, atBats)
    careerSteals = @($career | Sort-Object stolenBases -Descending | Select-Object -First 10 playerName, stolenBases)
    teamHomeRuns = @($teamSeasons | Sort-Object homeRuns -Descending | Select-Object -First 10 year, teamName, homeRuns)
    teamSteals = @($teamSeasons | Sort-Object stolenBases -Descending | Select-Object -First 10 year, teamName, stolenBases)
}

$output = Join-Path (Split-Path $DataFile) "report.json"
$report | ConvertTo-Json -Depth 6 | Set-Content $output -Encoding utf8
Write-Host "Wrote $output"
