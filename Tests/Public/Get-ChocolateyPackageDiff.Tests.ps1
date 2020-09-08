#Requires -Modules chocolatey-diff

Describe "Get-ChocolateyPackageDiff" {

    BeforeAll {
        Mock 'Get-ChocolateyPackage' { $true } -ModuleName 'chocolatey-diff'
        Mock 'Expand-Archive' { $true } -ModuleName 'chocolatey-diff'
        Mock 'Invoke-DiffTool' { $true } -ModuleName 'chocolatey-diff'
        Mock 'Remove-Item' { $true } -ModuleName 'chocolatey-diff'
        Mock 'Test-IsBinary' { $true } -ModuleName 'chocolatey-diff' -ParameterFilter { $Path -eq 'TestDrive:\MyFile.exe' }
        Mock 'Test-IsBinary' { $false } -ModuleName 'chocolatey-diff' -ParameterFilter { $Path -like 'TestDrive:\chocolatey*' }
        Mock 'Get-ChildItem' { $true } -ModuleName 'chocolatey-diff' -ParameterFilter { $Exclude -And $Path }
        Mock 'Write-Warning' { $true } -ModuleName 'chocolatey-diff'
        Mock 'Get-ChildItem' {
            @(
                @{
                    FullName = 'TestDrive:\chocolateyInstall.ps1'
                }
                @{
                    FullName = 'TestDrive:\chocolateyUninstall.ps1'
                }
                @{
                    FullName = 'TestDrive:\MyFile.exe'
                }
            )
        } -ModuleName 'chocolatey-diff' -ParameterFilter { $Recurse -And $File }
    }

    Context 'Only packagename tests' {

        BeforeAll {
            Mock 'Get-LatestApprovedPackageVersion' { $approvedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                packageName       = 'MyPackage'
                approvedVersion   = @{
                    Version = '0.1.0'
                }
                unapprovedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                Get-ChocolateyPackageDiff -packageName $packageName

                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-LatestUnapprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-ChocolateyPackage -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Invoke-DiffTool -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Test-IsBinary -Exactly 4 -ModuleName 'chocolatey-diff'
                Should -Invoke Expand-Archive -Exactly 2
                Should -Invoke Remove-Item -Exactly 4
                Should -Invoke Write-Warning -Exactly 3
            }
        }
    }

    Context 'With CompareFolder tests' {

        BeforeAll {
            Mock 'Get-LatestApprovedPackageVersion' { $approvedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                packageName       = 'MyPackage'
                approvedVersion   = @{
                    Version = '0.1.0'
                }
                unapprovedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                Get-ChocolateyPackageDiff -packageName $packageName -compareFolder

                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-LatestUnapprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-ChocolateyPackage -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Invoke-DiffTool -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Expand-Archive -Exactly 2
                Should -Invoke Remove-Item -Exactly 4
                Should -Invoke Write-Warning -Exactly 1
            }
        }
    }

    Context 'With KeepFiles tests' {

        BeforeAll {
            Mock 'Get-LatestApprovedPackageVersion' { $approvedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                packageName       = 'MyPackage'
                approvedVersion   = @{
                    Version = '0.1.0'
                }
                unapprovedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                Get-ChocolateyPackageDiff -packageName $packageName -keepFiles

                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-LatestUnapprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-ChocolateyPackage -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Invoke-DiffTool -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Expand-Archive -Exactly 2
                Should -Invoke Remove-Item -Exactly 0
                Should -Invoke Write-Warning -Exactly 2
            }
        }
    }

    Context 'With an old file' {

        BeforeAll {
            Mock 'Get-LatestApprovedPackageVersion' { $approvedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $false } -ParameterFilter { $PathType -eq 'Leaf' -and $Path -eq 'TestDrive:\chocolateyUninstall.ps1' }  -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                packageName       = 'MyPackage'
                approvedVersion   = @{
                    Version = '0.1.0'
                }
                unapprovedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                Get-ChocolateyPackageDiff -packageName $packageName

                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-LatestUnapprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-ChocolateyPackage -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Invoke-DiffTool -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Test-IsBinary -Exactly 4 -ModuleName 'chocolatey-diff'
                Should -Invoke Expand-Archive -Exactly 2
                Should -Invoke Remove-Item -Exactly 4
                Should -Invoke Write-Warning -Exactly 4
            }
        }
    }

    Context 'With an new file' {

        BeforeAll {
            $downloadFolder = Join-Path ([System.IO.Path]::GetTempPath()) "chocodiff"
            $oldFolderName = Join-Path $downloadFolder "MyPackage.0.1.0"
            Mock 'Get-LatestApprovedPackageVersion' { $approvedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
            Mock 'Get-ChildItem' { } -ModuleName 'chocolatey-diff' -ParameterFilter { $Path -eq $oldFolderName }
        }

        #region Discovery
        $testCases = @(
            @{
                packageName       = 'MyPackage'
                approvedVersion   = @{
                    Version = '0.1.0'
                }
                unapprovedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                Get-ChocolateyPackageDiff -packageName $packageName

                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-LatestUnapprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-ChocolateyPackage -Exactly 2 -ModuleName 'chocolatey-diff'
                Should -Invoke Test-IsBinary -Exactly 3 -ModuleName 'chocolatey-diff'
                Should -Invoke Expand-Archive -Exactly 2
                Should -Invoke Remove-Item -Exactly 4
                Should -Invoke Write-Warning -Exactly 4
            }
        }
    }

    Context 'Without approved version tests' {

        BeforeAll {
            Mock 'Get-LatestApprovedPackageVersion' {  } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                packageName       = 'MyPackage'
                unapprovedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                { Get-ChocolateyPackageDiff -packageName $packageName } | Should -Throw
                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
            }
        }
    }

    Context 'Without unapproved version tests' {

        BeforeAll {
            Mock 'Get-LatestApprovedPackageVersion' { $approvedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Get-LatestUnapprovedPackageVersion' { $unapprovedVersion } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                packageName     = 'MyPackage'
                approvedVersion = @{
                    Version = '0.2.0'
                }
            }
        )
        #endregion Discovery

        It 'Diff for package <packageName> with an approved and unapproved version' -TestCases $testCases {
            InModuleScope 'chocolatey-diff' -Parameters @{
                packageName = $packageName
            } {
                Param ($packageName)
                { Get-ChocolateyPackageDiff -packageName $packageName } | Should -Throw
                Should -Invoke Get-LatestApprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
                Should -Invoke Get-LatestUnapprovedPackageVersion -Exactly 1 -ModuleName 'chocolatey-diff'
            }
        }
    }
}

