# Export functions that start with capital letter, others are private
# Include file names that start with capital letters, ignore others
$ScriptRoot = Split-Path $MyInvocation.MyCommand.Definition

$Classes = @( Get-ChildItem -Path $ScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue )
$Public = @( Get-ChildItem -Path $ScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $ScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach ($import in @($Classes + $Public + $Private)) {
  Try {
    . $import.fullname
  }
  Catch {
    Write-Error -Message "Failed to import function $($import.fullname): $_"
  }
}

Export-ModuleMember -Function $Public.Basename
