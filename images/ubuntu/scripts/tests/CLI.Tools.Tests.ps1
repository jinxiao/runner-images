$cloudProviderPath = "/imagegeneration/cloud-provider"
$isAwsBuild = (Test-Path $cloudProviderPath) -and ((Get-Content $cloudProviderPath -Raw).Trim() -eq "aws")

Describe "AWS" {
    It "AWS CLI" {
        "aws --version" | Should -ReturnZeroExitCode
    }

    It "Session Manager Plugin for the AWS CLI" {
        session-manager-plugin 2>&1 | Out-String | Should -Match "plugin was installed successfully"
    }

    It "AWS SAM CLI" {
        "sam --version" | Should -ReturnZeroExitCode
    }
}

Describe "GitHub CLI" {
    It "gh cli" {
        "gh --version" | Should -ReturnZeroExitCode
    }
}
