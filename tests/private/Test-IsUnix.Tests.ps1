$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

Describe "Test-IsUnix tests" {
    InModuleScope chocolatey-diff {
        Context 'Test-IsUnix Tests' {
            $testCases = @(
                @{ Platform = 'Win32NT'; Expected = $false }
                @{ Platform = 'Unix'; Expected = $true }
            )
            It "Checks if Test-IsUnix for <Platform> is <Expected>" -TestCases $testCases {
                Param($Platform, $Expected)
                $CurrentPlatform = $PSVersionTable.Platform
                $PSVersionTable.Platform = $Platform
                Test-IsUnix | Should -Be $Expected
                $PSVersionTable.Platform = $CurrentPlatform
            }
        }
    }
}