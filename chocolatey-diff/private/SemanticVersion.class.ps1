# basically stolen from Kim - https://github.com/AdmiringWorm
# Apache-2.0 License

class SemanticVersion {
    [version]$VersionOnly;
    [string]$Raw;
    [string]$Tag;

    [SemanticVersion] static create([string]$version) {
        $tagIndex = $version.IndexOf('-')
        $semVer = [SemanticVersion]::new()
        $semVer.Raw = $version
        if ($tagIndex -gt 0) {
            $semVer.VersionOnly = [version]::Parse($version.Substring(0, $tagIndex))
            $semVer.Tag = $version.Substring($tagIndex + 1)
        }
        else {
            $semVer.VersionOnly = [version]::Parse($version)
            $semVer.Tag = [string]::Empty
        }

        return $semVer;
    }

    [string] ToString() {
        return $this.Raw
    }
}
