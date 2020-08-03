# basically stolen from Kim - https://github.com/AdmiringWorm
# Apache-2.0 License

class VersionData {
    [uri]$url;
    [SemanticVersion]$version;
    [string]$status;
    [bool]$listed;
    [bool]$isNew;
    [bool]$isUpdated;
}