$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

$global:TextTestFile = If ($PSVersionTable.Platform -eq "Unix") { '/etc/hosts' } else { Join-Path -Path $env:windir -ChildPath "win.ini" }
$global:BinaryTestFile = If ($PSVersionTable.Platform -eq "Unix") { '/bin/cat' } else { Join-Path -Path $env:windir -ChildPath "notepad.exe" }

Describe "Test-IsBinary tests" {
    InModuleScope chocolatey-diff {
        Context 'Test-IsBinary Tests' {
            $testCases = @(
                @{ Expected = $false; File = If (Test-Path (Join-Path -Path $env:windir -ChildPath "win.ini") -PathType Leaf) { Join-Path -Path $env:windir -ChildPath "win.ini" } else { '/etc/hosts' }; }
                @{ Expected = $true; File = If (Test-Path (Join-Path -Path $env:windir -ChildPath "notepad.exe") -PathType Leaf) { Join-Path -Path $env:windir -ChildPath "notepad.exe" } else { '/bin/cat' }; }
            )
            It "Test-IsBinary should return <Expected> on file <File>" -TestCases $testCases {
                Param($File, $Expected)
                Test-IsBinary -Path $File | Should -Be $Expected
            }

        }
    }
}