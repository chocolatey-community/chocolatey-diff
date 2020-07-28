
function Get-TempPath {
    if (Test-IsUnix) {
        "/tmp/chocodiff"
    }
    else {
        Join-Path $env:Temp "chocodiff"
    }
}
