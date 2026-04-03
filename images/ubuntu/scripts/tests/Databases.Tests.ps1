Describe "PostgreSQL" {
    It "PostgreSQL Service" {
        "sudo systemctl start postgresql" | Should -ReturnZeroExitCode
        "pg_isready" | Should -OutputTextMatchingRegex "/var/run/postgresql:5432 - accepting connections"
        "sudo systemctl stop postgresql" | Should -ReturnZeroExitCode
    }

    It "PostgreSQL version should correspond to the version in the toolset" {
        $toolsetVersion = (Get-ToolsetContent).postgresql.version
        # Client version
        (psql --version).split()[-1] | Should -BeLike "$toolsetVersion*"
        # Server version
        (pg_config --version).split()[-1] | Should -BeLike "$toolsetVersion*"
    }
}
