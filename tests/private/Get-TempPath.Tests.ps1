$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

Describe "Get-TempPath tests" {
    InModuleScope chocolatey-diff {
        Context 'Get-TempPath Tests' {
            $testCases = @(
                @{ Expected = Join-Path ([System.IO.Path]::GetTempPath()) "chocodiff" }
            )
            It "Checks if Temp folder is <Expected>" -TestCases $testCases {
                Param($Expected)
                Get-TempPath | Should -BeExactly $Expected
            }
        }
    }
}