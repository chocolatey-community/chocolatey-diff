#Requires -Modules chocolatey-diff

Describe "Get-ChocolateyRepositoryUrl tests" {

    AfterAll {
        Remove-Item Env:\repositoryUrl -ErrorAction SilentlyContinue
    }

    Context 'Get-ChocolateyRepositoryUrl Tests' {

        #region Discovery
        $testCases = @(
            @{
                RepositoryUrl = '';
                Expected = 'https://chocolatey.org/api/v2/'
            }
            @{
                RepositoryUrl = 'some_url';
                Expected = 'some_url'
            }
        )
        #endregion Discovery

        It 'retrieves the url <Expected> when env var is <RepositoryUrl>' -TestCases $testCases {
            Param($RepositoryUrl, $Expected)
            $env:repositoryUrl = $RepositoryUrl
            InModuleScope 'chocolatey-diff' { Get-ChocolateyRepositoryUrl } | Should -BeExactly $Expected
        }
    }
}
