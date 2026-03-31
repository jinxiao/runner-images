param(
    [String] [Parameter (Mandatory=$true)] $TemplatePath,
    [String] [Parameter (Mandatory=$true)] $BuildTemplateName,
    [ValidateSet("azure", "aws")] [String] [Parameter (Mandatory=$false)] $CloudProvider = "azure",
    [String] [Parameter (Mandatory=$false)] $ClientId,
    [String] [Parameter (Mandatory=$false)] $ClientSecret,
    [String] [Parameter (Mandatory=$false)] $Location,
    [String] [Parameter (Mandatory=$true)] $ImageName,
    [String] [Parameter (Mandatory=$false)] $ImageResourceGroupName,
    [String] [Parameter (Mandatory=$false)] $TempResourceGroupName,
    [String] [Parameter (Mandatory=$false)] $SubscriptionId,
    [String] [Parameter (Mandatory=$false)] $TenantId,
    [String] [Parameter (Mandatory=$true)] $ImageOS, # e.g. "ubuntu22", "ubuntu24" or "win22", "win25"
    [String] [Parameter (Mandatory=$false)] $UseAzureCliAuth = "false",
    [String] [Parameter (Mandatory=$false)] $AzurePluginVersion = "2.3.3",
    [String] [Parameter (Mandatory=$false)] $AmazonPluginVersion,
    [String] [Parameter (Mandatory=$false)] $VirtualNetworkName,
    [String] [Parameter (Mandatory=$false)] $VirtualNetworkRG,
    [String] [Parameter (Mandatory=$false)] $VirtualNetworkSubnet,
    [String] [Parameter (Mandatory=$false)] $AllowedInboundIpAddresses = "[]",
    [String] [Parameter (Mandatory=$false)] $AwsRegion,
    [String] [Parameter (Mandatory=$false)] $AwsArchitecture,
    [String] [Parameter (Mandatory=$false)] $AwsSubnetId,
    [String] [Parameter (Mandatory=$false)] $AwsSourceAmi,
    [String[]] [Parameter (Mandatory=$false)] $AwsAmiUsers = @(),
    [String] [Parameter (Mandatory=$false)] $AwsIamInstanceProfile,
    [String] [Parameter (Mandatory=$false)] $AwsInstanceType,
    [String] [Parameter (Mandatory=$false)] $WindowsPasswordTimeout = "30m",
    [hashtable] [Parameter (Mandatory=$false)] $Tags = @{}
)

if (-not (Test-Path $TemplatePath))
{
    Write-Error "'-TemplatePath' parameter is not valid. You have to specify correct Template Path"
    exit 1
}

$buildName = $($BuildTemplateName).Split(".")[1]
$InstallPassword = [System.GUID]::NewGuid().ToString().ToUpper()
$isWindowsImage = $ImageOS -like "win*"

$SensitiveData = @(
    'OSType',
    'StorageAccountLocation',
    'OSDiskUri',
    'OSDiskUriReadOnlySas',
    'TemplateUri',
    'TemplateUriReadOnlySas',
    ':  ->'
)

$providerSource = if ($CloudProvider -eq "aws") { "amazon-ebs.image" } else { "azure-arm.image" }
$buildTarget = "$buildName.$providerSource"
$azure_tags = $Tags | ConvertTo-Json -Compress
$aws_tags = $azure_tags
$aws_ami_users_json = if ($AwsAmiUsers.Count -gt 0) { $AwsAmiUsers | ConvertTo-Json -Compress } else { $null }

Write-Host "Show Packer Version"
packer --version

Write-Host "Download packer plugins"
if ($CloudProvider -eq "aws") {
    # Mixed template directories still contain azure-arm sources, so Packer needs
    # the Azure plugin installed even when we only build the amazon-ebs target.
    if ([string]::IsNullOrWhiteSpace($AmazonPluginVersion)) {
        packer plugins install github.com/hashicorp/amazon
    } else {
        packer plugins install github.com/hashicorp/amazon $AmazonPluginVersion
    }

    if ([string]::IsNullOrWhiteSpace($AzurePluginVersion)) {
        packer plugins install github.com/hashicorp/azure
    } else {
        packer plugins install github.com/hashicorp/azure $AzurePluginVersion
    }
} else {
    if ([string]::IsNullOrWhiteSpace($AzurePluginVersion)) {
        packer plugins install github.com/hashicorp/azure
    } else {
        packer plugins install github.com/hashicorp/azure $AzurePluginVersion
    }
}

Write-Host "Validate packer template"
packer validate -syntax-only -only $buildTarget $TemplatePath

Write-Host "Build $buildName VM"
if ($CloudProvider -eq "aws") {
    $buildArgs = @(
        "build"
        "-only"
        $buildTarget
        "-var"
        "aws_ami_name=$ImageName"
        "-var"
        "aws_tags=$aws_tags"
        "-var"
        "image_os=$ImageOS"
        "-var"
        "install_password=$InstallPassword"
        "-color=false"
    )

    if (-not [string]::IsNullOrWhiteSpace($AwsRegion)) {
        $buildArgs += @("-var", "aws_region=$AwsRegion")
    }
    if (-not [string]::IsNullOrWhiteSpace($aws_ami_users_json)) {
        $buildArgs += @("-var", "aws_ami_users=$aws_ami_users_json")
    }
    if (-not [string]::IsNullOrWhiteSpace($AwsArchitecture)) {
        $buildArgs += @("-var", "aws_architecture=$AwsArchitecture")
    }
    if (-not [string]::IsNullOrWhiteSpace($AwsIamInstanceProfile)) {
        $buildArgs += @("-var", "aws_iam_instance_profile=$AwsIamInstanceProfile")
    }
    if (-not [string]::IsNullOrWhiteSpace($AwsInstanceType)) {
        $buildArgs += @("-var", "aws_instance_type=$AwsInstanceType")
    }
    if (-not [string]::IsNullOrWhiteSpace($AwsSourceAmi)) {
        $buildArgs += @("-var", "aws_source_ami=$AwsSourceAmi")
    }
    if (-not [string]::IsNullOrWhiteSpace($AwsSubnetId)) {
        $buildArgs += @("-var", "aws_subnet_id=$AwsSubnetId")
    }
    if ($isWindowsImage -and (-not [string]::IsNullOrWhiteSpace($WindowsPasswordTimeout))) {
        $buildArgs += @("-var", "windows_password_timeout=$WindowsPasswordTimeout")
    }

    $buildArgs += $TemplatePath

    packer @buildArgs `
            | Where-Object {
                $currentString = $_
                $sensitiveString = $SensitiveData | Where-Object { $currentString -match $_ }
                $sensitiveString -eq $null
            }
} else {
    packer build    -only $buildTarget `
                    -var "client_id=$ClientId" `
                    -var "client_secret=$ClientSecret" `
                    -var "install_password=$InstallPassword" `
                    -var "location=$Location" `
                    -var "image_os=$ImageOS" `
                    -var "managed_image_name=$ImageName" `
                    -var "managed_image_resource_group_name=$ImageResourceGroupName" `
                    -var "subscription_id=$SubscriptionId" `
                    -var "temp_resource_group_name=$TempResourceGroupName" `
                    -var "tenant_id=$TenantId" `
                    -var "virtual_network_name=$VirtualNetworkName" `
                    -var "virtual_network_resource_group_name=$VirtualNetworkRG" `
                    -var "virtual_network_subnet_name=$VirtualNetworkSubnet" `
                    -var "allowed_inbound_ip_addresses=$($AllowedInboundIpAddresses)" `
                    -var "use_azure_cli_auth=$UseAzureCliAuth" `
                    -var "azure_tags=$azure_tags" `
                    -color=false `
                    $TemplatePath `
        | Where-Object {
            #Filter sensitive data from Packer logs
            $currentString = $_
            $sensitiveString = $SensitiveData | Where-Object { $currentString -match $_ }
            $sensitiveString -eq $null
        }
}
