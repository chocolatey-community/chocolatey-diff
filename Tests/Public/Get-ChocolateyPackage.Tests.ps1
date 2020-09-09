#Requires -Modules chocolatey-diff

Describe "Get-ChocolateyPackage" {

    Context 'Tests' {

        BeforeAll {
            Mock 'Invoke-WebRequest' { "Mocked" } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $true } -ParameterFilter { $PathType -eq 'Leaf' } -ModuleName 'chocolatey-diff'
            Mock 'Test-Path' { $false } -ParameterFilter { $PathType -eq 'Container' } -ModuleName 'chocolatey-diff'
            Mock 'New-Item' { $true } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                parameters = @{
                    packageName     = 'MyPackage'
                    packageVersion  = '0.1.0'
                    useZipExtension = $true
                }
            }
            @{
                parameters = @{
                    packageName     = 'MyPackage'
                    packageVersion  = '0.1.0'
                    useZipExtension = $false
                }
            }
        )
        #endregion Discovery

        It 'Download package' -TestCases $testCases {
            Param($parameters)
            InModuleScope 'chocolatey-diff' -Parameters @{
                parameters = $parameters
            } {
                Param ($parameters)
                Get-ChocolateyPackage @parameters

                Should -Invoke Invoke-WebRequest -Exactly 1
                Should -Invoke New-Item -Exactly 1
                Should -Invoke Test-Path -Exactly 2
            }
        }
    }
}

