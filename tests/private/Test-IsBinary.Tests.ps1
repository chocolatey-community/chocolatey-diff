#Requires -Modules chocolatey-diff

Describe "Test-IsBinary tests" {

        Context 'Test-IsBinary Tests' {

        #region Discovery
        $testCases = @(
            @{
                Expected = $false;
                File = If (![string]::IsNullOrEmpty($env:windir)) { Join-Path -Path $env:windir -ChildPath "win.ini" } else { '/etc/hosts' };
            }
            @{
                Expected = $true;
                File = If (![string]::IsNullOrEmpty($env:windir)) { Join-Path -Path $env:windir -ChildPath "notepad.exe" } else { '/bin/cat' };
            }
        )
        #endregion Discovery

        It "Test-IsBinary should return <Expected> on file <File>" -TestCases $testCases {
            Param($File, $Expected)
            InModuleScope 'chocolatey-diff' -Parameters @{ File = $File } {
                Param($File)
                Test-IsBinary -Path $File
            } | Should -Be $Expected
        }
    }
}