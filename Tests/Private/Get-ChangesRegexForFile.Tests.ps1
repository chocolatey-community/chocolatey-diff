#Requires -Modules chocolatey-diff

Describe "Get-ChangesRegexForFile" {

    AfterAll {
        Remove-Item Env:\galleryUrl -ErrorAction SilentlyContinue
    }

    Context 'Normal Tests' {

        #region Discovery
        $testCases = @(
            @{
                Filename = 'TestDrive:\MyPackage.nuspec'
                Result   = @(
                    "<version>.*<\/version>",
                    "<releaseNotes>.*<\/releaseNotes>"
                )
            }
            @{
                Filename = 'TestDrive:\chocolateyInstall.ps1'
                Result   = @(
                    "^[$]?\s*url(32|64)?\s*=\s*[\`"'].*[\`"']",
                    "^[$]?\s*file(32|64)?\s*=\s*[\`"'].*[\`"']",
                    "^[$]?\s*checksum(32|64)?\s*=\s*[\`"'].*[\`"']",
                    "^[$]?\s*checksumType(32|64)?\s*=\s*[\`"'].*[\`"']",
                    "^[$]version\s*=\s*[\`"'].*[\`"']"
                )
            }
        )
        #endregion Discovery

        It 'Fetches the regexes for <Filename>' -TestCases $testCases {
            Param($Filename, $Result)
            $Regexes = InModuleScope 'chocolatey-diff' -Parameters @{
                Filename = $Filename
            } {
                Param ($Filename)
                Get-ChangesRegexForFile -Filename $Filename
            }
            $Regexes | Should -Not -BeNullOrEmpty
            $Regexes | Should -HaveCount $Result.Count
            $Regexes | Should -Be $Result
        }
    }
    Context 'Unknown file Tests' {

        #region Discovery
        $testCases = @(
            @{
                Filename = 'TestDrive:\Helpers.ps1'
                Result   = ''
            }
        )
        #endregion Discovery

        It 'Fetches the regexes for <Filename>' -TestCases $testCases {
            Param($Filename, $Result)
            $Regexes = InModuleScope 'chocolatey-diff' -Parameters @{
                Filename = $Filename
            } {
                Param ($Filename)
                Get-ChangesRegexForFile -Filename $Filename
            }
            $Regexes | Should -BeNullOrEmpty
        }
    }
}
