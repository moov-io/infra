#!/bin/bash
set -e

mkdir -p ./bin/

# Collect all our files for processing
MODNAME=$(go list .)
GOPKGS=($(go list ./...))
GOFILES=($(find . -type f -not -path "./nginx/*" -name '*.go' | grep -v client | grep -v vendor))

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

# gitleaks
# Right now there are some false positives which make it harder to scan
# See: https://github.com/zricethezav/gitleaks/issues/394
if [[ "$EXPERIMENTAL" == *"gitleaks"* ]]; then
    if [[ "$OS_NAME" != "windows" ]]; then
        wget -q -O gitleaks.tar.gz "https://github.com/zricethezav/gitleaks/releases/download/v8.5.3/gitleaks_8.5.3_""$UNAME""_x64.tar.gz"
        tar xf gitleaks.tar.gz gitleaks
        mv gitleaks ./bin/gitleaks

        echo "gitleaks version: "$(./bin/gitleaks version)
        ./bin/gitleaks detect --no-git --verbose
        echo "finished gitleaks check"
    fi
fi

# nancy (vulnerable dependencies)
if [[ "$OS_NAME" == "linux" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.33/nancy-v1.0.33-linux-amd64; fi
if [[ "$OS_NAME" == "osx" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.33/nancy-v1.0.33-darwin-amd64; fi
if [[ "$OS_NAME" != "windows" ]]; then
    chmod +x ./bin/nancy
    ./bin/nancy --version

    ignored_deps=(
        # Consul Enterprise
        CVE-2018-19653
        CVE-2020-13250
        CVE-2020-7219
        # Vault Enterprise
        CVE-2020-10660
        CVE-2020-10661
        CVE-2020-13223
        CVE-2020-7220
        # etcd
        CVE-2020-15114
        CVE-2020-15115
        CVE-2020-15136
        # jwt-go
        CVE-2020-26160
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
    go list -json -deps | ./bin/nancy --skip-update-check --loud sleuth --exclude-vulnerability "$ignored"

    echo "" # newline
    echo "finished nancy check"
fi

# Allow for build tags to be set
if [[ "$GOTAGS" != "" ]]; then
    GOLANGCI_TAGS=" --build-tags $GOTAGS "
    GOTAGS=" -tags $GOTAGS "
fi

# golangci-lint
if [[ "$OS_NAME" != "windows" ]]; then
    wget -q -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.45.2

    enabled="-E=asciicheck,bidichk,bodyclose,exhaustive,durationcheck,gosec,misspell,nolintlint,rowserrcheck,sqlclosecheck"
    if [ -n "$GOLANGCI_LINTERS" ];
    then
        enabled="$enabled"",$GOLANGCI_LINTERS"
    fi

    ./bin/golangci-lint --version
    ./bin/golangci-lint $GOLANGCI_FLAGS run "$enabled" --verbose --skip-dirs="(admin|client)" --timeout=5m --disable=errcheck $GOLANGCI_TAGS

    echo "finished golangci-lint check"
fi

## Clear GOARCH and GOOS for testing...
GOARCH=''
GOOS=''
GORACE='-race'
if [[ "$CGO_ENABLED" == "0" ]];
then
    GORACE=''
fi
if [[ "$OS_NAME" == "osx" ]];
then
    version=$(sw_vers -productVersion)
    if echo "$version" | grep "12.";
    then
        echo "Skipping -race flag on macOS $version"
        GORACE=""
    fi
fi

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
    go test $GOTAGS "$gotest_packages" "$GORACE" -short -coverprofile=coverage.txt -covermode=atomic "$GOTEST_FLAGS"
fi
if [[ "$OS_NAME" != "windows" ]]; then
    if [[ "$COVER_THRESHOLD" == "disabled" ]]; then
        go test $GOTAGS "$gotest_packages" "$GORACE" -count 1 "$GOTEST_FLAGS"
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
                   -count 1 "$GOTEST_FLAGS"

                coverage=$(go tool cover -func="$dir"/coverage.txt | grep total | grep -Eo '[0-9]+\.[0-9]+')
                if [[ "$coverage" > "0.0" ]];
                then
                    coveredStatements=$(echo "$coveredStatements" + "$coverage" | bc)
                    maximumCoverage=$((maximumCoverage+100))
                fi
            done
        else
            # Otherwise just run Go tests without profiling
            go test $GOTAGS "$gotest_packages" "$GORACE" -coverprofile=coverage.txt -covermode=atomic -count 1 "$GOTEST_FLAGS"
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
        echo "SUCCESS: project has sufficient statement coverage"
    fi
else
    echo "Skipping code coverage threshold, consider setting COVER_THRESHOLD. (Example: 85.0)"
fi

echo "finished running Go tests"
