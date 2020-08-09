Write-Host 'Running test script' -ForegroundColor Yellow
Write-Host "Current working directory: $pwd"

$resultsFile = '.\TestsResults.xml'
$testFiles   = Get-ChildItem "$pwd\tests" -Recurse | Where-Object {$_.FullName -match 'Tests.ps1$'} | Select-Object -ExpandProperty FullName
$sourceFiles = Get-ChildItem "$pwd\chocolatey-diff" -Recurse | Where-Object {$_.FullName -match 'ps1$'} | Select-Object -ExpandProperty FullName
$results     = Invoke-Pester -Script $testFiles -CodeCoverage $sourceFiles -OutputFormat NUnitXml -OutputFile $resultsFile -PassThru

if (($results.FailedCount -gt 0) -or ($results.PassedCount -eq 0) -or ($null -eq $results)) {
  throw "$($results.FailedCount) tests failed."
} else {
  Write-Host 'All tests passed' -ForegroundColor Green
}
