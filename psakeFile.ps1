properties {
    $projectRoot = $ENV:BHProjectPath
    if(-not $projectRoot) {
        $projectRoot = $PSScriptRoot
    }

    $sut = $env:BHModulePath
    $tests = Join-Path -Path $projectRoot -ChildPath 'Tests'
    $outputDir = Join-Path -Path $projectRoot -ChildPath 'out'
    $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $psVersion = $PSVersionTable.PSVersion.Major
    $pathSeperator = [IO.Path]::PathSeparator

}

task OutputDir {
    $outputModVerDir
}

task default -depends Test

task Init {
    "`nSTATUS: Testing with PowerShell $psVersion"
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
} -description 'Initialize build environment'

task Test -Depends Init, Analyze, Pester -description 'Run test suite'

task Analyze -Depends Build {
    $analysis = Invoke-ScriptAnalyzer -Path $outputModVerDir -Settings ./ScriptAnalyzerSettings.psd1 -Recurse -Verbose:$false
    $errors   = $analysis | Where-Object {$_.Severity -eq 'Error'}
    $warnings = $analysis | Where-Object {$_.Severity -eq 'Warning'}

    if (($errors.Count -eq 0) -and ($warnings.Count -eq 0)) {
        '    PSScriptAnalyzer passed without errors or warnings'
    }

    if (@($errors).Count -gt 0) {
        $errors | Format-Table -AutoSize
        Write-Error -Message 'One or more Script Analyzer errors were found. Build cannot continue!'
    }

    if (@($warnings).Count -gt 0) {
        $warnings | Format-Table -AutoSize
        Write-Warning -Message 'One or more Script Analyzer warnings were found. These should be corrected.'
    }
} -description 'Run PSScriptAnalyzer'

task Pester -Depends Build {
    Push-Location
    Set-Location -PassThru $outputModDir
    if(-not $ENV:BHProjectPath) {
        Set-BuildEnvironment -Path $PSScriptRoot\..
    }

    $origModulePath = $env:PSModulePath
    if ( $env:PSModulePath.split($pathSeperator) -notcontains $outputDir ) {
        $env:PSModulePath = ($outputDir + $pathSeperator + $origModulePath)
    }

    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue -Verbose:$false
    Import-Module -Name $outputModDir -Force -Verbose:$false
    $testResultsXml = Join-Path -Path $outputDir -ChildPath 'testResults.xml'
    $codeCoverageXml =  Join-Path -Path $outputDir -ChildPath 'jacoco.xml'
    $sourceFiles = Get-ChildItem $sut -Recurse | Where-Object { $_.FullName -match 'ps1$' } | Select-Object -ExpandProperty FullName
    $testResults = Invoke-Pester -Path $tests -PassThru -OutputFile $testResultsXml -OutputFormat NUnitXml -CodeCoverage $sourceFiles -CodeCoverageOutputFile $codeCoverageXml

    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
    Pop-Location
    $env:PSModulePath = $origModulePath
} -description 'Run Pester tests'

Task Publish -Depends Test {
    "    Publishing version [$($manifest.ModuleVersion)] to PSGallery..."
    Publish-Module -Path $outputModVerDir -NuGetApiKey $env:PSGALLERY_API_KEY -Repository PSGallery
}

task Clean -depends Init {
    Remove-Module -Name $env:BHProjectName -Force -ErrorAction SilentlyContinue

    if (Test-Path -Path $outputModVerDir) {
        Remove-Item -Path $outputModVerDir -Recurse -Force > $null
    }
    "    Cleaned previous output directory [$outputModVerDir]"
} -description 'Cleans module output directory'

task Build -depends Clean {

    if (-not (Test-Path -Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory > $null
    }
    New-Item -Path $outputModVerDir -ItemType Directory > $null
    Copy-Item -Path (Join-Path -Path $sut -ChildPath *) -Destination $outputModVerDir -Recurse

    "    Created build module at [$outputModVerDir]"
} -description 'Builds module from source'
