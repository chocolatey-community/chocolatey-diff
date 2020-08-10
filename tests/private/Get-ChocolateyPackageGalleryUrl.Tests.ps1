$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module chocolatey-diff | Remove-Module -Force

Import-Module $here\..\..\chocolatey-diff\chocolatey-diff.psm1 -Force

Describe "Get-ChocolateyPackageGalleryUrl tests" {
    InModuleScope chocolatey-diff {
        Context 'Get-ChocolateyPackageGalleryUrl Tests' {
            # Tip to implemented this by @vexx32
            $testCases = @(
                @{ GalleryUrl = ''; Expected = 'https://chocolatey.org/packages' }
                @{ GalleryUrl = 'some_url'; Expected = 'some_url' }
            )
            It 'retrieves the url <Expected> when env var is <GalleryUrl>' -TestCases $testCases {
                Param($GalleryUrl, $Expected)
                $env:galleryUrl = $GalleryUrl
                Get-ChocolateyPackageGalleryUrl | Should -BeExactly $Expected
            }
        }
    }
}