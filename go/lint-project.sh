#!/bin/bash
set -e

mkdir -p ./bin/

# Collect all our files for processing
GOFILES=$(find . -type f -name '*.go' | grep -v client | grep -v vendor)

# Check gofmt
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    test -z $(gofmt -s -l $GOFILES)
fi

# Misspell
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -O misspell.tar.gz https://github.com/client9/misspell/releases/download/v0.3.4/misspell_0.3.4_linux_64bit.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -O misspell.tar.gz https://github.com/client9/misspell/releases/download/v0.3.4/misspell_0.3.4_mac_64bit.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    tar xf misspell.tar.gz
    cp ./misspell ./bin/misspell
    misspell -error -locale US $GOFILES
fi

# staticcheck
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -O staticcheck.tar.gz https://github.com/dominikh/go-tools/releases/download/2020.1.3/staticcheck_linux_amd64.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -O staticcheck.tar.gz https://github.com/dominikh/go-tools/releases/download/2020.1.3/staticcheck_darwin_amd64.tar.gz; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    tar xf staticcheck.tar.gz
    cp ./staticcheck/staticcheck ./bin/staticcheck
    staticcheck ./...
fi

# nancy (vulnerable dependencies)
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then curl -L -o ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v0.2.3/nancy-linux.amd64-v0.2.3; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then curl -L -o ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v0.2.3/nancy-darwin.amd64-v0.2.3; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    chmod +x ./bin/nancy
    go list -m all | ./bin/nancy -exclude-vulnerability CVE-2020-7220,CVE-2020-10660,CVE-2020-10661 # Vault Enterprise, needs gocloud.dev release
fi

# golangci-lint
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    wget -O - -q https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.25.1
    ./bin/golangci-lint run --skip-dirs="(admin|client)" --timeout=2m --disable=errcheck
fi

# gocyclo
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then wget -O ./bin/gocyclo https://github.com/adamdecaf/gocyclo/releases/download/2019-08-09/gocyclo-linux-amd64; fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then wget -O ./bin/gocyclo https://github.com/adamdecaf/gocyclo/releases/download/2019-08-09/gocyclo-darwin-amd64; fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    chmod +x ./bin/gocyclo
    ./bin/gocyclo -over 25 $GOFILES
fi

# Run 'go test'
if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
    # Just run short tests on Windows as we don't have Docker support in tests worked out for the database tests
    go test ./... -race -short -coverprofile=coverage.txt -covermode=atomic
fi
if [[ "$TRAVIS_OS_NAME" != "windows" ]]; then
    go test ./... -race -coverprofile=coverage.txt -covermode=atomic
fi
