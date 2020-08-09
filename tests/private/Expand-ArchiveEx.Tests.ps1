$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

Describe "Get-TempPath tests" {
    InModuleScope chocolatey-diff {
        Context 'Get-TempPath Tests' {
            It "Get-TempPath" {
                Get-TempPath | Should -Match "chocodiff"
            }
        }
    }

}