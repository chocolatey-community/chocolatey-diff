#Requires -Modules chocolatey-diff

Describe "Get-VersionData tests" {

    Context 'Get-VersionData normal Tests ' {

        BeforeAll {
            Mock 'Invoke-RestMethod' { [xml] "<?xml version=`"1.0`" encoding=`"utf-8`" standalone=`"yes`"?>
            <entry xml:base=`"http://chocolatey.org/api/v2/`" xmlns:d=`"http://schemas.microsoft.com/ado/2007/08/dataservices`" xmlns:m=`"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata`" xmlns=`"http://www.w3.org/2005/Atom`">
              <m:properties xmlns:m=`"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata`" xmlns:d=`"http://schemas.microsoft.com/ado/2007/08/dataservices`">
                <d:GalleryDetailsUrl>https://chocolatey.org/packages/${PackageName}/${PackageVersion}</d:GalleryDetailsUrl>
                <d:Published m:type=`"Edm.DateTime`">${PublishedDate}</d:Published>
                <d:IsApproved m:type=`"Edm.Boolean`">${IsApproved}</d:IsApproved>
                <d:PackageStatus>${PackageStatus}</d:PackageStatus>
                <d:PackageSubmittedStatus>${PackageSubmittedStatus}</d:PackageSubmittedStatus>
              </m:properties>
            </entry>" } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                PackageName            = 'MyPackage';
                PackageVersion         = '0.1.0';
                PackageStatus          = 'Submitted';
                PackageSubmittedStatus = 'Ready';
                PackageExpectedStatus  = 'submitted';
            }
            @{
                PackageName            = 'MyPackage';
                PackageVersion         = '0.1.0';
                PackageStatus          = 'Submitted';
                PackageSubmittedStatus = 'Waiting';
                PackageExpectedStatus  = 'waiting';
            }
            @{
                PackageName            = 'MyPackage';
                PackageVersion         = '0.1.0';
                PackageStatus          = 'Approved';
                PackageSubmittedStatus = 'Ready';
                PackageExpectedStatus  = 'approved';
            }
            @{
                PackageName            = 'MyPackage';
                PackageVersion         = '0.1.0-beta';
                PackageStatus          = 'Exempted';
                PackageSubmittedStatus = 'Ready';
                PackageExpectedStatus  = 'exempted';
            }
        )
        #endregion Discovery

        It 'Fetch Package VersionData for <PackageName> package v<PackageVersion> with status <PackageStatus> and Submitted status <PackageSubmittedStatus> ' -TestCases $testCases {
            Param($PackageName, $PackageVersion, $PackageStatus, $PackageSubmittedStatus, $PackageExpectedStatus)
            $PublishedDate = '1900-01-01T00:00:00'
            $IsApproved = $PackageStatus -eq "Approved"

            if ($PackageStatus -eq "Approved" -or $PackageStatus -eq "Exempted") {
                $PublishedDate = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddThh:mm:ss.fff')
            }
            $versionData = InModuleScope 'chocolatey-diff' -Parameters @{
                PackageName    = $PackageName;
                PackageVersion = $PackageVersion
            } {
                Param ($PackageName, $PackageVersion)
                Get-VersionData -packageName $PackageName -version ([SemanticVersion]::create($PackageVersion))
            }
            $versionData | Should -Not -BeNullOrEmpty
            $versionData.version | Should -Be $PackageVersion
            $versionData.listed | Should -Be ($PackageStatus -eq "Approved" -or $PackageStatus -eq "Exempted")
            $versionData.url | Should -Be "https://chocolatey.org/packages/${PackageName}/${PackageVersion}"
            $versionData.status | Should -Be $PackageExpectedStatus
        }
    }
    Context 'Get-VersionData rejected Tests ' {

        BeforeAll {
            Mock 'Invoke-RestMethod' { throw "Resource not found for the segment 'Packages'." } -ModuleName 'chocolatey-diff'
        }

        #region Discovery
        $testCases = @(
            @{
                PackageName            = 'MyPackage';
                PackageVersion         = '0.1.0';
                PackageStatus          = 'Rejected';
                PackageSubmittedStatus = 'Ready';
                PackageExpectedStatus  = 'rejected';
            }
        )
        #endregion Discovery

        It 'Fetch Package VersionData for <PackageName> package v<PackageVersion> with status <PackageStatus> and Submitted status <PackageSubmittedStatus> ' -TestCases $testCases {
            Param($PackageName, $PackageVersion, $PackageStatus, $PackageSubmittedStatus, $PackageExpectedStatus)
            $versionData = InModuleScope 'chocolatey-diff' -Parameters @{
                PackageName    = $PackageName;
                PackageVersion = $PackageVersion
            } {
                Param ($PackageName, $PackageVersion)
                Get-VersionData -packageName $PackageName -version ([SemanticVersion]::create($PackageVersion))
            }
            $versionData | Should -Not -BeNullOrEmpty
            $versionData.version | Should -Be $PackageVersion
            $versionData.listed | Should -Be ($PackageStatus -eq "Approved" -or $PackageStatus -eq "Exempted")
            $versionData.url | Should -Be "https://chocolatey.org/packages/${PackageName}/${PackageVersion}"
            $versionData.status | Should -Be $PackageExpectedStatus
        }
    }
}

