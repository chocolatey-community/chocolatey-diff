#Requires -Modules chocolatey-diff

Describe "Get-ChocolateyPackageGalleryUrl tests" {

    AfterAll {
        Remove-Item Env:\galleryUrl -ErrorAction SilentlyContinue
    }

    Context 'Get-ChocolateyPackageGalleryUrl Tests' {

        #region Discovery
        $testCases = @(
            @{
                GalleryUrl = '';
                Expected = 'https://chocolatey.org/packages'
            }
            @{
                GalleryUrl = 'some_url';
                Expected = 'some_url'
            }
        )
        #endregion Discovery

        It 'retrieves the url <Expected> when env var is <GalleryUrl>' -TestCases $testCases {
            Param($GalleryUrl, $Expected)
            $env:galleryUrl = $GalleryUrl
            InModuleScope 'chocolatey-diff' { Get-ChocolateyPackageGalleryUrl } | Should -BeExactly $Expected
        }
    }
}