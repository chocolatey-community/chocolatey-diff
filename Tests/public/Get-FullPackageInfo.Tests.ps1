#Requires -Modules chocolatey-diff

Describe "Get-FullPackageInfo tests" {

    Context 'Get-FullPackageInfo normal Tests ' {

        BeforeAll {
            Mock 'Invoke-RestMethod' { $PackageVersions } -ModuleName 'chocolatey-diff'
            Mock 'Get-VersionData' {
                $Data = $PackageVersionData.($version.Raw)
                $result = @{
                    version       = $version
                    Listed        = $Data.PackageStatus -eq 'approved'
                    PackageStatus = $Data.PackageStatus
                }
                Write-Output $result
            } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                PackageName        = 'MyPackage';
                PackageVersions    = "0.1.0","0.2.0"
                PackageVersionData = @{
                    '0.1.0' = @{
                        PackageStatus = 'approved';
                        PublishedDate = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddThh:mm:ss.fff')
                    }
                    '0.2.0' = @{
                        PackageStatus = 'submitted';
                        PublishedDate = '1900-01-01T00:00:00'
                    }
                }
            }
        )
        #endregion Discovery

        It 'Fetch Full package info for <PackageName> package <PackageVersions>' -TestCases $testCases {
            Param($PackageName, $PackageVersions, $PackageVersionData)
            $pkgInfo = InModuleScope 'chocolatey-diff' -Parameters @{
                PackageName = $PackageName
            } {
                Param ($PackageName)
                Get-FullPackageInfo -PackageId $PackageName
                Should -Invoke Invoke-RestMethod -Exactly 1
                Should -Invoke Get-VersionData -Exactly $PackageVersionData.Count
            }
            $pkgInfo | Should -Not -BeNullOrEmpty
            $pkgInfo.Id | Should -BeExactly $PackageName
            $pkgInfo.Versions | Should -HaveCount $PackageVersionData.Count
        }
    }
}

