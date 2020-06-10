#!/bin/bash
set -e

mkdir -p ./bin/

# Collect all our files for processing
GOFILES=($(find . -type f -name '*.go' | grep -v client | grep -v vendor))

# Set TRAVIS_OS_NAME if it's empty (local dev)
if [[ "$TRAVIS_OS_NAME" == "" ]]; then
    if [[ $(uname -s) == "Darwin" ]]; then
        export TRAVIS_OS_NAME=osx
    else
        export TRAVIS_OS_NAME=linux
    fi
fi
echo "running go linters for $TRAVIS_OS_NAME"

# Check gofmt
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    set +e
    code=0
    for file in "${GOFILES[@]}"
    do
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
fi

# Misspell
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -q -O misspell.tar.gz https://github.com/client9/misspell/releases/download/v0.3.4/misspell_0.3.4_linux_64bit.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -q -O misspell.tar.gz https://github.com/client9/misspell/releases/download/v0.3.4/misspell_0.3.4_mac_64bit.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    tar xf misspell.tar.gz
    cp ./misspell ./bin/misspell

    for file in "${GOFILES[@]}"
    do
        ./bin/misspell -error -locale US $file
    done
fi

# gitleaks
# Right now there are some false positives which make it harder to scan
# See: https://github.com/zricethezav/gitleaks/issues/394
if [[ "$EXPERIMENTAL" == *"gitleaks"* ]]; then
    if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -q -O ./bin/gitleaks https://github.com/zricethezav/gitleaks/releases/download/v4.3.1/gitleaks-linux-amd64; fi
    if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -q -O ./bin/gitleaks https://github.com/zricethezav/gitleaks/releases/download/v4.3.1/gitleaks-darwin-amd64; fi

    if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
        chmod +x ./bin/gitleaks

        # Scan a few of the most recent commits
        depth=10
        if [ -n "$GITLEAKS_DEPTH" ]; then
            depth=$GITLEAKS_DEPTH
        fi
        ./bin/gitleaks --depth=$depth --repo-path=$(pwd) --pretty --verbose
    fi
fi

# staticcheck
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -q -O staticcheck.tar.gz https://github.com/dominikh/go-tools/releases/download/2020.1.4/staticcheck_linux_amd64.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -q -O staticcheck.tar.gz https://github.com/dominikh/go-tools/releases/download/2020.1.4/staticcheck_darwin_amd64.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    tar xf staticcheck.tar.gz
    cp ./staticcheck/staticcheck ./bin/staticcheck

    # Grab directories with Go files but not 'admin' or 'client'
    GODIRS=$(find ./** -mindepth 1 -type f -name "*.go" | grep -v admin | grep -v client | xargs -n1 -I '{}' dirname {} | sort -u)
    ./bin/staticcheck $GODIRS
fi

# nancy (vulnerable dependencies)
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v0.2.7/nancy-linux.amd64-v0.2.7; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v0.2.7/nancy-darwin.amd64-v0.2.7; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    chmod +x ./bin/nancy
    # Ignore Consul and Vault Enterprise, they need a gocloud.dev release
    go list -m all | ./bin/nancy -exclude-vulnerability CVE-2018-19653,CVE-2020-7219,CVE-2020-7220,CVE-2020-10660,CVE-2020-10661
    echo "" # newline
fi

# golangci-lint
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    wget -q -O - -q https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.27.0
    ./bin/golangci-lint run --skip-dirs="(admin|client)" --timeout=2m --disable=errcheck
fi

# gocyclo
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -q -O ./bin/gocyclo https://github.com/adamdecaf/gocyclo/releases/download/2019-08-09/gocyclo-linux-amd64; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -q -O ./bin/gocyclo https://github.com/adamdecaf/gocyclo/releases/download/2019-08-09/gocyclo-darwin-amd64; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    chmod +x ./bin/gocyclo

    args='-over 25'
    if [ -n "$GOCYCLO_LIMIT" ]; then
        args="-over $GOCYCLO_LIMIT"
    fi
    for file in "${GOFILES[@]}"
    do
        ./bin/gocyclo $args $file
    done
fi

# Run exhaustive to verify Enums aren't missing cases
if [[ "$EXPERIMENTAL" == *"exhaustive"* ]]; then
    go get github.com/nishanths/exhaustive/cmd/exhaustive
    echo "Running nishanths/exhaustive"

    if [ -n "$DEFAULT_SIGNIFIES_EXHAUSTIVE" ]; then
        exhaustive -default-signifies-exhaustive ./...
    else
        exhaustive ./...
    fi
fi

# Run 'go test'
if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
    # Just run short tests on Windows as we don't have Docker support in tests worked out for the database tests
    go test ./... -race -short -coverprofile=coverage.txt -covermode=atomic
fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    go test ./... -race -coverprofile=coverage.txt -covermode=atomic
fi
