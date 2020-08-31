$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force


Describe "Invoke-DiffTool tests" {
    InModuleScope chocolatey-diff {
        BeforeAll {
            Mock -CommandName Start-Process {return $true} -ParameterFilter {$NoNewWindow -eq $true; $Wait -eq $true } -Verifiable 
        }
        Context 'Invoke-DiffTool Tests' {
            $testCases = @(
                @{ 
                    Difftool = '';
                    Platform = 'Win32NT';
                    Expected = "C:\Program Files\KDiff3\bin\diff.exe"
                }
                @{ 
                    Difftool = '';
                    Platform = 'Unix';
                    Expected = "diff"
                }
                @{ 
                    Difftool = 'C:\Program Files\KDiff3\bin\diff3.exe';
                    Platform = 'Win32NT';
                    Expected = "C:\Program Files\KDiff3\bin\diff3.exe"
                }
            )
            It "Checks if Invoke-DiffTool for <Platform> calls <Expected>" -TestCases $testCases {
                Param($Platform, $Expected, $Difftool)
                $env:difftool = $Difftool
                $CurrentPlatform = $PSVersionTable.Platform
                $PSVersionTable.Platform = $Platform
                Invoke-DiffTool -Path1 "/path/to/my/file" -Path2 "/path/to/my/file2"
                Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $Expected }
                $PSVersionTable.Platform = $CurrentPlatform
            }
        }
    }
}