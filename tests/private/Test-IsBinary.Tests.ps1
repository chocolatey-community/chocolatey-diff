$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

$global:TextTestFile = If ($PSVersionTable.Platform -eq "Unix") { '/etc/hosts' } else { Join-Path -Path $env:windir -ChildPath "win.ini" }
$global:BinaryTestFile = If ($PSVersionTable.Platform -eq "Unix") { '/bin/cat' } else { Join-Path -Path $env:windir -ChildPath "notepad.exe" }

Describe "Test-IsBinary tests" {
    InModuleScope chocolatey-diff {
        Context 'Test-IsBinary Tests' {
            It "Test-IsBinary Non-Binary" {
                Test-IsBinary -Path $global:TextTestFile | Should -BeFalse
            }

            It "Test-IsBinary Binary" {
                Test-IsBinary -Path $global:BinaryTestFile | Should -BeTrue
            }
        }
    }

}