## Golang Linter Script

### Dependency CVE Checking

- `IGNORED_CVES`: List of [CVEs to ignore in dependencies](https://github.com/sonatype-nexus-community/nancy#via-file). (Example: `CVE-2020-26160,CVE-2022-0001`)

### Experiments

- `EXPERIMENTAL`: List of additional checks to perform. (Example: `gitleaks,...`)
   - Current experiments: `gitleaks`, `govulncheck`, `shuffle`

### Go Linters

- `GOLANGCI_LINTERS`: List of additional [Go linters to run with golangci-lint](https://golangci-lint.run/usage/linters/). (Example: `gosec`)

### Testing

- `COVER_THRESHOLD`: Minimum threshold of code statements required to be ran during tests. (Example: `85.0`)
- `GOTEST_FLAGS`: Additional flags to include on `go test` commands. (Example `-test.shuffle=on`)
- `GOTEST_PKGS`: Selector of packages to test (Examples: `./...`, `./internal/foo/`)
- `PROFILE_GOTEST`: Run each package with CPU and memory profiling. (Example: `yes`)
- `SKIP_TESTS`: Don't run any Go tests when set to `yes`.
