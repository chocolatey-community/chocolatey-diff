$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force


Describe "Test-IsUnix tests" {
    InModuleScope chocolatey-diff {
        Context 'Test-IsUnix Tests' {
            $global:result = If ($PSVersionTable.Platform -eq "Unix") { $True } else { $False }
            It "Test-IsUnix" {
                Test-IsUnix | Should -Be $global:result
            }
        }
    }
}