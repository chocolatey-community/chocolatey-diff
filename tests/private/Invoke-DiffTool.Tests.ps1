#Requires -Modules chocolatey-diff

Describe "Invoke-DiffTool tests" {

    BeforeAll {
        $CurrentPlatform = $PSVersionTable.Platform
    }

    AfterAll {
        $PSVersionTable.Platform = $CurrentPlatform
    }

    Context 'Invoke-DiffTool Tests' {

        #region Discovery
        $testCases = @(
            @{
                Difftool = '';
                Platform = 'Win32NT';
                Expected = "C:\Program Files\KDiff3\bin\diff.exe"
            }
            @{
                Difftool = 'C:\Program Files\KDiff3\bin\diff3.exe';
                Platform = 'Win32NT';
                Expected = "C:\Program Files\KDiff3\bin\diff3.exe"
            }
            @{
                Difftool = '';
                Platform = 'Unix';
                Expected = "diff"
            }
        )
        #endregion Discovery

        BeforeAll {
            Mock 'Start-Process' { $true } -ParameterFilter {
                $NoNewWindow -and $Wait
            } -ModuleName 'chocolatey-diff'
        }

        It "Checks if Invoke-DiffTool for <Platform> calls <Expected>" -TestCases $testCases {
            Param($Platform, $Expected, $Difftool)
            $env:difftool = $Difftool
            $PSVersionTable.Platform = $Platform
            InModuleScope 'chocolatey-diff' {
                Invoke-DiffTool -Path1 "/path/to/my/file" -Path2 "/path/to/my/file2"
                Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $Expected }
            }
        }
    }
}