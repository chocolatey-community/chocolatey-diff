#Requires -Modules chocolatey-diff

Describe "Get-LatestUnapprovedPackageVersion" {

    Context 'Normal Tests' {

        BeforeAll {
            Mock 'Get-FullPackageInfo' { Write-Output $PackageData } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                PackageName = 'MyPackage'
                PackageData = @{
                    Id       = 'MyPackage'
                    Versions = @(
                        @{
                            Version = '0.1.0'
                            Status  = 'approved'
                            Listed  = $true
                        }
                        @{
                            Version = '0.2.0'
                            Status  = 'submitted'
                            Listed  = $false
                        }
                    )
                }
            }
        )
        #endregion Discovery

        It 'Fetch latest approved package info for <PackageName>' -TestCases $testCases {
            Param($PackageName, $PackageData)
            $pkgInfo = InModuleScope 'chocolatey-diff' -Parameters @{
                PackageName = $PackageName
            } {
                Param ($PackageName)
                Get-LatestUnapprovedPackageVersion -PackageId $PackageName
                Should -Invoke Get-FullPackageInfo -Exactly 1 -ModuleName 'chocolatey-diff'
            }
            $pkgInfo | Should -Not -BeNullOrEmpty
            $pkgInfo.Version.ToString() | Should -BeExactly '0.2.0'
        }
    }
}
