$cloudProviderPath = 'C:\image\cloud-provider.txt'
$isAwsBuild = (Test-Path $cloudProviderPath) -and ((Get-Content $cloudProviderPath -Raw).Trim() -eq 'aws')

Describe "Azure CLI" -Skip:($isAwsBuild) {
    It "Azure CLI" {
        "az --version" | Should -ReturnZeroExitCode
    }
}

Describe "Azure DevOps CLI" -Skip:($isAwsBuild) {
    It "az devops" {
        "az devops -h" | Should -ReturnZeroExitCode
    }
}

Describe "Aliyun CLI" -Skip:(Test-IsWin25) {
    It "Aliyun CLI" {
        "aliyun version" | Should -ReturnZeroExitCode
    }
}


Describe "AWS" {
    It "AWS CLI" {
        "aws --version" | Should -ReturnZeroExitCode
    }

    It "Session Manager Plugin for the AWS CLI" {
        @(session-manager-plugin) -Match '\S' | Out-String | Should -Match "plugin was installed successfully"
    }

    It "AWS SAM CLI" {
        "sam --version" | Should -ReturnZeroExitCode
    }
}


Describe "GitHub CLI" {
    It "gh" {
        "gh --version" | Should -ReturnZeroExitCode
    }
}
