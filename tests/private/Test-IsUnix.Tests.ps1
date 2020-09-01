#Requires -Modules chocolatey-diff

Describe "Test-IsUnix tests" {

    BeforeAll {
        $CurrentPlatform = $PSVersionTable.Platform
    }

    AfterAll {
        $PSVersionTable.Platform = $CurrentPlatform
    }

    Context 'Test-IsUnix Tests' {

        #region Discovery
        $testCases = @(
            @{
                Platform = 'Win32NT';
                Expected = $false
            }
            @{
                Platform = 'Unix';
                Expected = $true
            }
        )
        #endregion Discovery

        It "Checks if Test-IsUnix for <Platform> is <Expected>" -TestCases $testCases {
            Param($Platform, $Expected)
            $PSVersionTable.Platform = $Platform
            InModuleScope 'chocolatey-diff' { Test-IsUnix } | Should -Be $Expected
        }
    }
}