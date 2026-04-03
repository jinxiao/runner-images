Import-Module "$PSScriptRoot/Helpers.psm1" -DisableNameChecking

if (Test-IsUbuntu24) {
    Get-ChildItem -Path $PSScriptRoot -Filter "*.Tests.ps1" |
        Where-Object { $_.BaseName -ne "Browsers.Tests" } |
        Sort-Object Name |
        ForEach-Object {
            Invoke-PesterTests ($_.BaseName -replace '\.Tests$', '')
        }
} else {
    Invoke-PesterTests "*"
}
