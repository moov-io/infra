## Golang Linter Script

### Experiments

- `EXPERIMENTAL`: List of additional checks to perform. (Example: `gitleaks,...`)
   - Current experiments: `gitleaks`, `govulncheck`, `shuffle`

### Go Linters

- `DISABLED_GOLANGCI_LINTERS`: Linters to disable in golangci-lint
- `GOLANGCI_LINTERS`: List of additional [Go linters to run with golangci-lint](https://golangci-lint.run/usage/linters/). (Example: `gosec`)
- `SKIP_GOLANGCI`: Don't run the golangci-lint checks
- `STRICT_GOLANGCI_LINTERS`: Enable more linters packaged with golangci-lint

### Testing

- `COVER_THRESHOLD`: Minimum threshold of code statements required to be ran during tests. (Example: `85.0`)
- `GOTEST_FLAGS`: Additional flags to include on `go test` commands. (Example `-test.shuffle=on`)
- `GOTEST_PKGS`: Selector of packages to test (Examples: `./...`, `./internal/foo/`)
- `PROFILE_GOTEST`: Run each package with CPU and memory profiling. (Example: `yes`)
- `SKIP_TESTS`: Don't run any Go tests when set to `yes`.
