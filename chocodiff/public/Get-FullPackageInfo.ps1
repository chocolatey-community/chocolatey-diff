
function Get-FullPackageInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $PackageId,

        [Parameter()]
        [psobject] $PackageInfo
    )

    $id = if ($PackageId) { 
        $PackageId 
    } 
    else { 
        $PackageInfo.Id 
    }

    $ver = if ($PackageInfo) {
        $PackageInfo.Version
    }
    else {
        ""
    }

    $pkgInfo = @{
        Id       = $id
        Url      = $null
        Version  = $null
        Versions = @()
    }

    # NOTE: this function intentionally does not use 'choco cli'!
    # direct http queries should be quicker and also OS-independent!
    # but still the following 'HTML scraping' is a VERY BAD IDEA - there should be a n API for this!
    # feel free to throw this away if there is a nicer way of getting the same information!

    $galleryBaseUrl = Get-ChocolateyPackageGalleryUrl
    $pkgInfo.Url = "${galleryBaseUrl}/${id}/${ver}"
    
    $page = Invoke-WebRequest -Uri $pkgInfo.Url
    
    $content = $page.Content
    
    $_rcv = [regex]"(&lt;version&gt;(?'version'(\d+\.?)+)&lt;\/version&gt;)"
    $pkgInfo.Version = Get-RegexGroupMatch $content $_rcv "version"

    $_rvg = [regex]"id=`"versionhistory`".*(?'historytable'<table.*\<\/table\>)"
    $histTable = Get-RegexGroupMatch $content $_rvg "historytable"    

    $_rvrow = [regex]"\<tr(?'row'.+?(?=\<\/tr))"

    # I'm so sorry ¯\_(ツ)_/¯
    $_rvtds = [regex]"\<td\s+\S+=`"version`"(.+?(?=\<))(.+?(?=\>))\>(?'version'.+?(?=\<\/)).+?(\<td(?=\>)>(?'downloads'.+?)(?=\<\/td))\<\/td\>.+?(\<td(?=\>)>(?'lastupdate'.+?)(?=\<\/td))\<\/td\>.+?(?'status'(\<td(.+?)(?=\<\/td))\<\/td\>)"
    
    function iText([psobject]$n) { $n.ChildNodes | % { iText $_ }; $n.InnerText } 
    
    $rowMatch = [regex]::Match($histTable, $_rvrow, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    while ($rowMatch.Success) {
        $r = [regex]::Match($rowMatch.Value, $_rvtds, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if ($r.Success) {
            $status = iText $([xml]$r.Groups['status'].Value.Trim())
            $statusList = @{ }
            $status | % { if ($_) { $statusList[$_.Trim()] = 1 } }

            $pkgInfo.Versions += @{
                Version    = $r.Groups['version'].Value.Trim().Split(" ")[1]
                Downloads  = $r.Groups['downloads'].Value.Trim()
                LastUpdate = $r.Groups['lastupdate'].Value.Trim()
                Status     = $statusList.Keys
            }
        }
        $rowMatch = $rowMatch.NextMatch()
    }
    Write-Output $pkgInfo
}

