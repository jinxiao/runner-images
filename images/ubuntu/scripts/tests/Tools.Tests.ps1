Import-Module "$PSScriptRoot/../helpers/Common.Helpers.psm1"
$cloudProviderPath = "/imagegeneration/cloud-provider"
$isAwsBuild = (Test-Path $cloudProviderPath) -and ((Get-Content $cloudProviderPath -Raw).Trim() -eq "aws")

Describe "Bicep" -Skip:($isAwsBuild) {
    It "Bicep" {
        "bicep --version" | Should -ReturnZeroExitCode
    }
}

Describe "Docker" {
    It "docker client" {
        $version=(Get-ToolsetContent).docker.components | Where-Object { $_.package -eq 'docker-ce-cli' } | Select-Object -ExpandProperty version
        If ($version -ne "latest") {
            $(sudo docker version --format '{{.Client.Version}}') | Should -BeLike "*$version*"
        }else{
            "sudo docker version --format '{{.Client.Version}}'" | Should -ReturnZeroExitCode
        }
    }

    It "docker server" {
        $version=(Get-ToolsetContent).docker.components | Where-Object { $_.package -eq 'docker-ce' } | Select-Object -ExpandProperty version
        If ($version -ne "latest") {
            $(sudo docker version --format '{{.Server.Version}}') | Should -BeLike "*$version*"
        }else{
            "sudo docker version --format '{{.Server.Version}}'" | Should -ReturnZeroExitCode
        }
    }

    It "docker client/server versions match" {
        $clientVersion = $(sudo docker version --format '{{.Client.Version}}')
        $serverVersion = $(sudo docker version --format '{{.Server.Version}}')
        $clientVersion | Should -Be $serverVersion
    }

    It "docker buildx" {
        $version=(Get-ToolsetContent).docker.plugins | Where-Object { $_.plugin -eq 'buildx' } | Select-Object -ExpandProperty version
        If ($version -ne "latest") {
            $(docker buildx version) | Should -BeLike "*$version*"
        }else{
            "docker buildx" | Should -ReturnZeroExitCode
        }
    }

    It "docker compose v2" {
        $version=(Get-ToolsetContent).docker.plugins | Where-Object { $_.plugin -eq 'compose' } | Select-Object -ExpandProperty version
        If ($version -ne "latest") {
            $(docker compose version --short) | Should -BeLike "*$version*"
        }else{
            "docker compose version --short" | Should -ReturnZeroExitCode
        }
    }

    It "docker-credential-ecr-login" {
        "docker-credential-ecr-login -v" | Should -ReturnZeroExitCode
    }
}

Describe "Ansible" {
    It "Ansible" {
        "ansible --version" | Should -ReturnZeroExitCode
    }
}

Describe "Bazel" {
    It "<ToolName>" -TestCases @(
        @{ ToolName = "bazel" }
        @{ ToolName = "bazelisk" }
    ) {
        "$ToolName --version"| Should -ReturnZeroExitCode
    }
}

Describe "gcc" {
    $testCases = (Get-ToolsetContent).gcc.Versions | ForEach-Object { @{GccVersion = $_} }

    It "gcc <GccVersion>" -TestCases $testCases {
        "$GccVersion --version" | Should -ReturnZeroExitCode
    }
}

Describe "R" -Skip:((-not (Test-IsUbuntu22))) {
    It "r" {
        "R --version" | Should -ReturnZeroExitCode
    }
}

Describe "Sbt" -Skip:((-not (Test-IsUbuntu22))) {
    It "sbt" {
        "sbt --version" | Should -ReturnZeroExitCode
    }
}

Describe "Selenium" {
    It "Selenium is installed" {
        $seleniumPath = Join-Path "/usr/share/java" "selenium-server.jar"
        $seleniumPath | Should -Exist
    }
}

Describe "Terraform" -Skip:((-not (Test-IsUbuntu22))) {
    It "terraform" {
        "terraform --version" | Should -ReturnZeroExitCode
    }
}

Describe "Zstd" {
    It "zstd" {
        "zstd --version" | Should -ReturnZeroExitCode
    }

    It "pzstd" {
        "pzstd --version" | Should -ReturnZeroExitCode
    }
}

Describe "Vcpkg" {
    It "vcpkg" {
        "vcpkg version" | Should -ReturnZeroExitCode
    }
}

Describe "Git" {
    It "git" {
        "git --version" | Should -ReturnZeroExitCode
    }

    It "git-ftp" {
        "git-ftp --version" | Should -ReturnZeroExitCode
    }
}

Describe "Git-lfs" {
    It "git-lfs" {
        "git-lfs --version" | Should -ReturnZeroExitCode
    }
}

Describe "Heroku" -Skip:((-not (Test-IsUbuntu22))) {
    It "heroku" {
        "heroku --version" | Should -ReturnZeroExitCode
    }
}

Describe "Homebrew" {
    It "homebrew" {
        "/home/linuxbrew/.linuxbrew/bin/brew --version" | Should -ReturnZeroExitCode
    }
}

Describe "Kubernetes tools" {
    It "kind" {
        "kind version" | Should -ReturnZeroExitCode
    }

    It "kubectl" {
        "kubectl version --client=true" | Should -OutputTextMatchingRegex "Client Version: v"
    }

    It "helm" {
        "helm version --short" | Should -ReturnZeroExitCode
    }

    It "minikube" {
        "minikube version --short" | Should -ReturnZeroExitCode
    }

    It "kustomize" {
        "kustomize version" | Should -ReturnZeroExitCode
    }
}

Describe "Leiningen" -Skip:((-not (Test-IsUbuntu22))) {
    It "leiningen" {
        "lein --version" | Should -ReturnZeroExitCode
    }
}

Describe "Conda" {
    It "conda" {
        "conda --version" | Should -ReturnZeroExitCode
    }
}

Describe "Packer" {
    It "packer" {
        "packer --version" | Should -ReturnZeroExitCode
    }
}

Describe "Containers" {
    $testCases = @("podman", "buildah", "skopeo") | ForEach-Object { @{ContainerCommand = $_} }

    It "<ContainerCommand>" -TestCases $testCases {
        "$ContainerCommand -v" | Should -ReturnZeroExitCode
    }

    # https://github.com/actions/runner-images/issues/7753
    It "podman networking" -TestCases "podman CNI plugins" {
        "podman network create -d bridge test-net" | Should -ReturnZeroExitCode
        "podman network ls" | Should -Not -OutputTextMatchingRegex "Error"
        "podman network rm test-net" | Should -ReturnZeroExitCode
    }

}

Describe "nvm" {
    It "nvm" {
        "source /etc/skel/.nvm/nvm.sh && nvm --version" | Should -ReturnZeroExitCode
    }
}

Describe "Python" {
    $testCases = @("python", "pip", "python3", "pip3") | ForEach-Object { @{PythonCommand = $_} }

    It "<PythonCommand>" -TestCases $testCases {
        "$PythonCommand --version" | Should -ReturnZeroExitCode
    }
}

Describe "yq" {
    It "yq" {
        "yq -V" | Should -ReturnZeroExitCode
    }
}

Describe "Ninja" {
    It "Ninja" {
        "ninja --version" | Should -ReturnZeroExitCode
    }
}
