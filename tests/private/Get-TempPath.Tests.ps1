$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

Describe "Get-TempPath tests" {
    InModuleScope chocolatey-diff {
        Context 'Get-TempPath Tests' {
            $testCases = @(
                @{ Platform = 'Win32NT'; Expected = Join-Path $env:Temp "chocodiff" }
                @{ Platform = 'Unix'; Expected = "/tmp/chocodiff" }
            )
            It "Checks if Temp folder for <Platform> is <Expected>" -TestCases $testCases {
                Param($Platform, $Expected)
                $CurrentPlatform = $PSVersionTable.Platform
                $PSVersionTable.Platform = $Platform
                Get-TempPath | Should -BeExactly $Expected
                $PSVersionTable.Platform = $CurrentPlatform
            }
        }
    }
}