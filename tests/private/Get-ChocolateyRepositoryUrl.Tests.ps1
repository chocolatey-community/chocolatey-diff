$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

Describe "Get-ChocolateyRepositoryUrl tests" {
    InModuleScope chocolatey-diff {
        Context 'Get-ChocolateyRepositoryUrl Tests' {
            # Tip to implemented this by @vexx32
            $testCases = @(
                @{ RepositoryUrl = ''; Expected = 'https://chocolatey.org/api/v2/' }
                @{ RepositoryUrl = 'some_url'; Expected = 'some_url' }
            )
            It 'retrieves the url <Expected> when env var is <RepositoryUrl>' -TestCases $testCases {
                Param($RepositoryUrl, $Expected)
                $env:repositoryUrl = $RepositoryUrl
                Get-ChocolateyRepositoryUrl | Should -BeExactly $Expected
            }
        }
    }
}