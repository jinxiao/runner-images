Describe "Nginx" {
    It "Nginx CLI" {
        "nginx -v" | Should -ReturnZeroExitCode
    }

    It "Nginx Service" {
        "sudo systemctl start nginx" | Should -ReturnZeroExitCode
        "sudo nginx -t" | Should -ReturnZeroExitCode
        "sudo systemctl stop nginx" | Should -ReturnZeroExitCode
    }
}
