# Create AWS Images with Packer

This fork can build the Ubuntu 22.04/24.04 and Windows 2022/2025 images on AWS by using the `amazon-ebs` Packer builder in the existing templates.

## Prerequisites

- Packer installed on the build host.
- AWS credentials available to Packer, for example via `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, and `AWS_REGION`.
- A subnet that allows the build host to reach the temporary EC2 instance over SSH for Ubuntu or WinRM for Windows.

## Automated image generation

Use the existing helper script and switch the provider to AWS:

```powershell
./images.CI/linux-and-win/build-image.ps1 `
  -CloudProvider aws `
  -TemplatePath ./images/ubuntu/templates `
  -BuildTemplateName build.ubuntu-24_04.pkr.hcl `
  -ImageName runner-image-ubuntu2404 `
  -ImageOS ubuntu24 `
  -AwsRegion ap-southeast-1 `
  -AwsSubnetId subnet-1234567890abcdef0 `
  -AwsInstanceType t3.medium `
  -Tags @{ Name = "runner-image-ubuntu2404"; ManagedBy = "packer" }
```

For Windows builds, point the script at the Windows templates and use a Windows image OS identifier such as `win22` or `win25`.

## Optional AWS inputs

- `AwsSourceAmi`: override the default base AMI lookup.
- `AwsArchitecture`: Linux-only, choose `x86_64` or `arm64`. Default is `x86_64`.
- `AwsIamInstanceProfile`: attach an instance profile to the temporary EC2 build instance.
- `AwsAmiUsers`: share the resulting AMI with specific AWS account IDs.
- `WindowsPasswordTimeout`: increase the time Packer waits for the initial Windows password on first boot.

The default Linux instance type is `t3.medium`. That works for `x86_64` builds only. For ARM builds, set both:

- `-AwsArchitecture arm64`
- `-AwsInstanceType t4g.medium` or another Graviton instance type

## Default source AMIs

If `AwsSourceAmi` is not provided, the templates use `source_ami_filter` and select the latest matching official image for the target OS:

- Ubuntu 22.04: Canonical owner `099720109477`, name pattern `ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-amd64-server-*`
- Ubuntu 22.04 ARM: Canonical owner `099720109477`, name pattern `ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-arm64-server-*`
- Ubuntu 24.04: Canonical owner `099720109477`, name pattern `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*`
- Ubuntu 24.04 ARM: Canonical owner `099720109477`, name pattern `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*`
- Windows 2022: AWS owner alias `amazon`, name pattern `Windows_Server-2022-English-Full-Base-*`
- Windows 2025: AWS owner alias `amazon`, name pattern `Windows_Server-2025-English-Full-Base-*`
