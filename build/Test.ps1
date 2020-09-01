Get-Module chocolatey-diff | Remove-Module -Force
Import-Module $PSScriptRoot\..\chocolatey-diff\chocolatey-diff.psd1 -Force

$Lines = '-' * 70

$PesterVersion = (Get-Module -Name Pester).Version
$PSVersion = $PSVersionTable.PSVersion

Write-Host $Lines
Write-Host "TEST: PowerShell Version: $PSVersion"
Write-Host "TEST: Pester Version: $PesterVersion"
Write-Host $Lines

$resultsFile = '.\testResults.xml'
$codecoverageFile = '.\jacoco-results.xml'
$testFiles = Get-ChildItem "$pwd\tests" -Recurse | Where-Object { $_.FullName -match 'Tests.ps1$' } | Select-Object -ExpandProperty FullName
$sourceFiles = Get-ChildItem "$pwd\chocolatey-diff" -Recurse | Where-Object { $_.FullName -match 'ps1$' } | Select-Object -ExpandProperty FullName
$results = Invoke-Pester -Script $testFiles -CodeCoverage $sourceFiles -CodeCoverageOutputFile $codecoverageFile -OutputFormat NUnitXml -OutputFile $resultsFile -PassThru

# $results = Invoke-Pester -Path $pwd -CI -Output Normal -PassThru

if (($results.FailedCount -gt 0) -or ($results.PassedCount -eq 0) -or ($null -eq $results)) {
    throw "$($results.FailedCount) tests failed."
}
else {
    Write-Host 'All tests passed' -ForegroundColor Green
}
