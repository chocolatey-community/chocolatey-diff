# Export functions that start with capital letter, others are private
# Include file names that start with capital letters, ignore others
$ScriptRoot = Split-Path $MyInvocation.MyCommand.Definition

$Public = @( Get-ChildItem -Path $ScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $ScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

foreach ($import in @($Public + $Private)) {
  Try {
    . $import.fullname
  }
  Catch {
    Write-Error -Message "Failed to import function $($import.fullname): $_"
  }
}

Export-ModuleMember -Function $Public.Basename