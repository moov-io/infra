#!/bin/bash
set -e

gitleaks_version=8.16.4
golangci_version=v1.53.2
nancy_version=v1.0.42
sqlvet_version=v1.1.5

# Set these to any non-blank value to disable the linter
disable_golangci=""
if [[ "$SKIP_GOLANGCI" != "" ]];
then
    disable_golangci="$SKIP_GOLANGCI"
fi
disable_nancy=""
if [[ "$SKIP_NANCY" != "" ]];
then
    disable_nancy="$SKIP_NANCY"
fi

mkdir -p ./bin/

# Collect all our files for processing
MODNAME=$(go list .)
GOPKGS=($(go list ./...))
GOFILES=($(find . -type f -not -path "./nginx/*" -name '*.go' -not -name '*.pb.go' | grep -v client | grep -v vendor))

# Print (and capture) the host's Go version
GO_VERSION=$(go version | grep -Eo '[0-9]\.[0-9]+\.?[0-9]?')
echo "Detected Go version $GO_VERSION"

# Set OS_NAME if it's empty (local dev)
OS_NAME=$TRAVIS_OS_NAME
UNAME=$(uname -s | tr [:upper:] [:lower:])
if [[ "$OS_NAME" == "" ]]; then
    if [[ "$UNAME" == "darwin" ]]; then
        export OS_NAME=osx
    else
        export OS_NAME=linux
    fi
fi
echo "running go linters for $OS_NAME"

# Check gofmt
if [[ "$OS_NAME" != "windows" ]]; then
    set +e
    code=0
    for file in "${GOFILES[@]}"
    do
        # Go 1.17 introduced a migration with build constraints
        # and they offer a migration with gofmt
        # See https://go.googlesource.com/proposal/+/master/design/draft-gobuild.md#transition for more details
        if [[ "$file" == "./pkged.go" ]];
        then
            gofmt -s -w pkged.go
        fi

        # Check the file's formatting
        test -z $(gofmt -s -l $file)
        if [[ $? != 0 ]];
        then
            code=1
            echo "$file is not formatted"
        fi
    done
    set -e
    if [[ $code != 0 ]];
    then
        exit $code
    fi

    echo "finished gofmt check"
fi

# Would be set to 'moov-io' or 'moovfinancial'
org=$(go mod why | head -n1  | awk -F'/' '{print $2}')

# Reject moovfinancial dependencies in moov-io projects
if [[ "$org" == "moov-io" ]];
then
    # Fail our build if we find moovfinancial dependencies
    if go list -m all | grep moovfinancial;
    then
        echo "Found github.com/moovfinancial dependencies in OSS. Please remove"
        exit 1
    fi
fi

# Allow for build tags to be set
if [[ "$GOTAGS" != "" ]]; then
    GOLANGCI_TAGS=" --build-tags $GOTAGS "
    GOTAGS=" -tags $GOTAGS "
fi

GORACE='-race'
if [[ "$CGO_ENABLED" == "0" || "$GOOS" == "js" || "$GOARCH" == "wasm" ]];
then
    GORACE=''
fi

# Build the source code (to discover compile errors prior to linting)
echo "Building Go source code"
go build $GORACE $GOTAGS $GOBUILD_FLAGS ./...
echo "SUCCESS: Go code built without errors"

# gitleaks (secret scanning, in-progress of a rollout)
run_gitleaks=true
if [[ "$OS_NAME" == "windows" ]]; then
    run_gitleaks=false
fi
if [[ "$org" != "moov-io" ]]; then
    run_gitleaks=false
fi
if [[ "$EXPERIMENTAL" == *"gitleaks"* ]]; then
    run_gitleaks=true
fi
if [[ "$DISABLE_GITLEAKS" != "" ]]; then
    run_gitleaks=false
fi
if [[ "$run_gitleaks" == "true" ]]; then
    wget -q -O gitleaks.tar.gz https://github.com/zricethezav/gitleaks/releases/download/v"$gitleaks_version"/gitleaks_"$gitleaks_version"_"$UNAME"_x64.tar.gz
    tar xf gitleaks.tar.gz gitleaks
    mv gitleaks ./bin/gitleaks

    echo "gitleaks version: "$(./bin/gitleaks version)
    ./bin/gitleaks detect --no-git --verbose
    echo "FINISHED gitleaks check"
fi

# nancy (vulnerable dependencies)
if [[ "$disable_nancy" != "" ]];
then
    echo "SKIPPING nancy check"
else
    # Download nancy
    if [[ "$OS_NAME" == "linux" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/"$nancy_version"/nancy-"$nancy_version"-linux-amd64; fi
    if [[ "$OS_NAME" == "osx" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/"$nancy_version"/nancy-"$nancy_version"-darwin-amd64; fi
    if [[ "$OS_NAME" != "windows" ]]; then
        chmod +x ./bin/nancy
        echo "STARTING nancy check"
        ./bin/nancy --version

        ignored_deps=(
            # hashicorp/vault enterprise issues
            CVE-2022-36129
            CVE-2022-36129
            # CWE-190: Integer Overflow or Wraparound
            sonatype-2021-3619
            # CWE-400: Uncontrolled Resource Consumption ('Resource Exhaustion')
            sonatype-2022-1745
        )
        ignored=$(printf ",%s" "${ignored_deps[@]}")
        ignored=${ignored:1}

        # Append additional CVEs
        if [ -n "$IGNORED_CVES" ];
        then
            ignored="$ignored"",""$IGNORED_CVES"
        fi

        # Clean nancy cache
        ./bin/nancy --clean-cache

        # Ignore Consul and Vault Enterprise, they need a gocloud.dev release
        go list -deps -f '{{with .Module}}{{.Path}} {{.Version}}{{end}}' ./... | ./bin/nancy --skip-update-check --loud sleuth --exclude-vulnerability "$ignored"

        echo "" # newline
        echo "FINISHED nancy check"
    fi
fi

## Run govulncheck which parses the compiled/used code for known vulnerabilities.
if [[ "$EXPERIMENTAL" == *"govulncheck"* ]]; then
# if [[ "$DISABLE_GOVULNCHECK" == "" ]]; then
    # Install govulncheck (no binary release available currently)
    go install golang.org/x/vuln/cmd/govulncheck@latest

    # Find govulncheck
    bin=""
    if which -s govulncheck > /dev/null;
    then
        bin=$(which govulncheck 2>&1 | head -n1)
    fi
    # Public Github runners path
    actions_path="/home/runner/go/bin/govulncheck"
    if [[ -f "$actions_path" ]];
    then
        bin="$actions_path"
    fi
    # Moov hosted runner paths
    actions_path="/home/actions/bin/govulncheck"
    if [[ -f "$actions_path" ]];
    then
        bin="$actions_path"
    fi

    # Run govulncheck
    if [[ "$bin" != "" ]];
    then
        echo "STARTING govulncheck check"
        "$bin" -v -test ./...
        echo "FINISHED govulncheck check"
    else
        echo "Can't find govulncheck..."
    fi
fi

# sqlvet
if [[ "$EXPERIMENTAL" == *"sqlvet"* ]]; then
    # Download only on linux or macOS
    if [[ "$OS_NAME" != "windows" ]]; then
        if [[ "$OS_NAME" == "linux" ]]; then wget -q -O sqlvet.tar.gz https://github.com/houqp/sqlvet/releases/download/"$sqlvet_version"/sqlvet-"$sqlvet_version"-linux-amd64.tar.gz; fi
        if [[ "$OS_NAME" == "osx" ]]; then wget -q -O sqlvet.tar.gz https://github.com/houqp/sqlvet/releases/download/"$sqlvet_version"/sqlvet-"$sqlvet_version"-darwin-amd64.tar.gz; fi
        tar xf sqlvet.tar.gz sqlvet
        mv sqlvet ./bin/sqlvet

        echo "sqlvet version: "$(./bin/sqlvet --version)
        ./bin/sqlvet .
        echo "FINISHED sqlvet check"
    else
        echo "sqlvet is not supported on windows"
    fi
fi

# golangci-lint
if [[ "$org" == "moov-io" ]];
then
    STRICT_GOLANGCI_LINTERS=yes
fi
if [[ "$OS_NAME" != "windows" ]]; then
    if [[ "$disable_golangci" != "" ]];
    then
        echo "SKIPPING golangci-lint"
    else
        # Download golangci-lint
        wget -q -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s "$golangci_version"

        enabled="-E=asciicheck,bidichk,bodyclose,durationcheck,exhaustive,exportloopref,forcetypeassert,gosec,misspell,nolintlint,rowserrcheck,sqlclosecheck,unused,wastedassign"
        if [ -n "$GOLANGCI_LINTERS" ];
        then
            enabled="$enabled"",$GOLANGCI_LINTERS"
        fi
        if [ -n "$SET_GOLANGCI_LINTERS" ];
        then
            enabled="-E=""$SET_GOLANGCI_LINTERS"
        fi

        # Additional linters for moov-io code
        if [[ "$STRICT_GOLANGCI_LINTERS" == "yes" ]];
        then
            enabled="$enabled"",dupword,gocheckcompilerdirectives,mirror,tenv"
        fi

        disabled="-D=depguard,errcheck"
        if [[ "$DISABLED_GOLANGCI_LINTERS" != "" ]];
        then
            disabled="-D=$DISABLED_GOLANGCI_LINTERS"
        fi

        echo "STARTING golangci-lint checks"
        ./bin/golangci-lint version
        ./bin/golangci-lint $GOLANGCI_FLAGS run "$enabled" "$disabled" --verbose --go="$GO_VERSION" --skip-dirs="(admin|client)" --timeout=5m $GOLANGCI_TAGS
        echo "FINISHED golangci-lint checks"
    fi
fi

if [[ "$SKIP_TESTS" == "yes" ]];
then
    echo "SKIPPING Go tests from env var"
    exit 0;
fi

## Clear GOARCH and GOOS for testing...
GOARCH=''
GOOS=''

gotest_packages="./..."
if [ -n "$GOTEST_PKGS" ];
then
    gotest_packages="$GOTEST_PKGS"
fi

coveredStatements=0
maximumCoverage=0

# Run 'go test'
if [[ "$OS_NAME" == "windows" ]]; then
    # Just run short tests on Windows as we don't have Docker support in tests worked out for the database tests
    go test $GOTAGS "$gotest_packages" "$GORACE" -short -coverprofile=coverage.txt -covermode=atomic $GOTEST_FLAGS
fi
# Add some default flags to every 'go test' case
if [[ "$GOTEST_FLAGS" == "" ]]; then
    # Enable test shuffling
    if [[ "$EXPERIMENTAL" == *"shuffle"* ]]; then
        GOTEST_FLAGS='-shuffle=on'
    fi
fi
if [[ "$OS_NAME" != "windows" ]]; then
    if [[ "$COVER_THRESHOLD" == "disabled" ]]; then
        go test $GOTAGS "$gotest_packages" "$GORACE" -count 1 $GOTEST_FLAGS
    else
        # Optionally profile each package
        if [[ "$PROFILE_GOTEST" == "yes" ]]; then
            for pkg in "${GOPKGS[@]}"
            do
                # fixup the sub-package for writing cpu/mem profile
                dir=${pkg#$MODNAME"/"}
                if [[ "$pkg" == "$dir" ]];
                then
                    dir="."
                fi

                go test $GOTAGS "$pkg" "$GORACE" \
                   -covermode=atomic \
                   -coverprofile="$dir"/coverage.txt \
                   -test.cpuprofile="$dir"/cpu.out \
                   -test.memprofile="$dir"/mem.out \
                   -count 1 $GOTEST_FLAGS

                coverage=$(go tool cover -func="$dir"/coverage.txt | grep total | grep -Eo '[0-9]+\.[0-9]+')
                if [[ "$coverage" > "0.0" ]];
                then
                    coveredStatements=$(echo "$coveredStatements" + "$coverage" | bc)
                    maximumCoverage=$((maximumCoverage+100))
                fi
            done
        else
            # Otherwise just run Go tests without profiling
            go test $GOTAGS "$gotest_packages" "$GORACE" -coverprofile=coverage.txt -covermode=atomic -count 1 $GOTEST_FLAGS
        fi
    fi
fi

# Verify Code Coverage Threshold
if [[ "$COVER_THRESHOLD" != "" ]]; then
    if [[ -f coverage.txt && "$PROFILE_GOTEST" != "yes" ]];
    then
        coveredStatements=$(go tool cover -func=coverage.txt | grep -E '^total:' | grep -Eo '[0-9]+\.[0-9]+')
        maximumCoverage=100
    fi

    avgCoverage=$(printf "%.1f" $(echo "($coveredStatements / $maximumCoverage)*100" | bc -l))
    echo "Project has $avgCoverage% statement coverage."

    if [[ "$avgCoverage" < "$COVER_THRESHOLD" ]]; then
        echo "ERROR: statement coverage is not sufficient, $COVER_THRESHOLD% is required"
        exit 1
    else
        echo "SUCCESS: project has sufficient statement coverage (over $COVER_THRESHOLD%)"
    fi
else
    echo "Skipping code coverage threshold, consider setting COVER_THRESHOLD. (Example: 85.0)"
fi

echo "finished running Go tests"
