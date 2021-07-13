[cmdletbinding()]
param(
    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string] $DiffTool,

    [Parameter(Mandatory = $false)]
    [int]$ModQueuePage = 1
)

Import-Module (Join-Path $PSScriptRoot "../chocolatey-diff/chocolatey-diff.psm1")

$packageBaseUri = "https://community.chocolatey.org/packages"
$queueUri = "$packageBaseUri/?q=&moderatorQueue=true&moderationStatus=ready-status&prerelease=false&sortOrder=package-download-count&page=$ModQueuePage"

$pkgsMatcher = [regex]"href\s*=\s*[`"|']\/packages\/(.+)\/(\d.+)#status[`"|']"

$htmlData = (Invoke-WebRequest -Uri $queueUri -UseBasicParsing).Content

$packages = $pkgsMatcher.Matches($htmlData) | Foreach-Object {
    $id = $_.Groups[1]
    $version = $_.Groups[2]
    @{
        id      = $id
        version = $version
        uri     = "{0}/{1}/{2}" -f $packageBaseUri, $id, $version
    }
}

$useDiffTool = ("" -ne $DiffTool)
if ($useDiffTool) {
    $env:difftool = $DiffTool
}

$packageIgnoreList = @()
foreach ($pkg in $packages) {
    "`n === {0} === " -f $pkg.id

    if ($packageIgnoreList -contains [string]$pkg.id) {
        " {0} is on ignore list -> NEXT!" -f $pkg.id
        continue;
    }

    $sel = Read-Host " (s) .. skip | (i) .. ignore | other .. let's do this!`nyour choice"
    if ("s" -eq $sel) {
        " SKIP! "
        continue;
    } elseif ("i" -eq $sel) {
        " ... ignore pkg id {0}" -f $pkg.id
        $packageIgnoreList += [string]$pkg.id
        continue;
    }

    try {
        $dArgs = @{
            PackageName       = $pkg.id
            NewPackageVersion = $pkg.version
            Verbose           = $VerbosePreference
        }
        if ($useDiffTool) {
            $dArgs.useDiffTool = $useDiffTool
            $dArgs.CompareFolder = $true
        }

        $diffObj = Get-ChocolateyPackageDiff @dArgs
        if (-not $useDiffTool) {
            $diffObj
        }
    } catch {
        $_.Exception.Message
    }

    " url: {0} " -f $pkg.uri

    Read-Host "press key to continue with next package..."
}
