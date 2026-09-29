param(
    [string]$SourceDir = (Join-Path $PSScriptRoot "..\source-data"),
    [string]$OutputDir = (Join-Path $PSScriptRoot "..\data")
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$people = @{}
Import-Csv (Join-Path $SourceDir "People.csv") | ForEach-Object {
    $people[$_.playerID] = (($_.nameFirst, $_.nameLast) -join " ").Trim()
}

$teamNames = @{}
Import-Csv (Join-Path $SourceDir "Teams.csv") | ForEach-Object {
    $teamNames["$($_.yearID)|$($_.teamID)"] = $_.name
}

$rows = Import-Csv (Join-Path $SourceDir "Batting.csv") | ForEach-Object {
    [PSCustomObject]@{
        playerID = $_.playerID
        playerName = $people[$_.playerID]
        year = [int]$_.yearID
        stint = [int]$_.stint
        teamID = $_.teamID
        teamName = $teamNames["$($_.yearID)|$($_.teamID)"]
        league = if ($_.lgID) { $_.lgID } else { "Unknown" }
        games = [int]$_.G
        atBats = [int]$_.AB
        runs = [int]$_.R
        hits = [int]$_.H
        doubles = [int]$_.'2B'
        triples = [int]$_.'3B'
        homeRuns = [int]$_.HR
        rbi = [int]$_.RBI
        stolenBases = [int]$_.SB
        caughtStealing = [int]$_.CS
        walks = [int]$_.BB
        strikeouts = [int]$_.SO
        hitByPitch = [int]$_.HBP
        sacrificeFlies = [int]$_.SF
    }
}

$rows | Export-Csv (Join-Path $OutputDir "batting.csv") -NoTypeInformation -Encoding utf8

$meta = [ordered]@{
    generated = (Get-Date).ToString("yyyy-MM-dd")
    rows = $rows.Count
    firstYear = ($rows | Measure-Object year -Minimum).Minimum
    lastYear = ($rows | Measure-Object year -Maximum).Maximum
    players = ($rows.playerID | Sort-Object -Unique).Count
    teams = ($rows.teamID | Sort-Object -Unique).Count
}
$meta | ConvertTo-Json | Set-Content (Join-Path $OutputDir "metadata.json") -Encoding utf8
Write-Host "Prepared $($rows.Count) rows."
