################################################################################
##  File:  Install-ChocolateyPackages.ps1
##  Desc:  Install common Chocolatey packages
################################################################################

$commonPackages = (Get-ToolsetContent).choco.common_packages
$cloudProviderPath = 'C:\image\cloud-provider.txt'
$isAwsBuild = ($env:CLOUD_PROVIDER -eq 'aws') -or ((Test-Path $cloudProviderPath) -and ((Get-Content $cloudProviderPath -Raw).Trim() -eq 'aws'))

if ($isAwsBuild) {
    $commonPackages = $commonPackages | Where-Object { $_.name -notin @('azcopy10', 'Bicep') }
}

foreach ($package in $commonPackages) {
    Install-ChocoPackage $package.name -Version $package.version -ArgumentList $package.args
}

Invoke-PesterTests -TestFile "ChocoPackages"
