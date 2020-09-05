#Requires -Modules chocolatey-diff

Describe "Get-TempPath tests" {

    Context 'Get-TempPath Tests' {

        #region Discovery
        $testCases = @(
            @{
                Expected = Join-Path ([System.IO.Path]::GetTempPath()) "chocodiff"
            }
        )
        #endregion Discovery

        It "Checks if Temp folder is <Expected>" -TestCases $testCases {
            Param($Expected)
            InModuleScope 'chocolatey-diff' { Get-TempPath } | Should -BeExactly $Expected
        }
    }
}