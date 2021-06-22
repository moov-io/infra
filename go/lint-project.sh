#!/bin/bash
set -e

mkdir -p ./bin/

# Collect all our files for processing
GOFILES=($(find . -type f -name '*.go' | grep -v client | grep -v vendor))

# Set OS_NAME if it's empty (local dev)
OS_NAME=$TRAVIS_OS_NAME
if [[ "$OS_NAME" == "" ]]; then
    if [[ $(uname -s) == "Darwin" ]]; then
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

# Would be set to 'moo-io' or 'moovfinancial'
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

# Verify we're using the latest version of github.com/moovfinancial/events if it's a dependency
if [[ "$org" == "moovfinancial" ]];
then
  eventsLibrary="github.com/moovfinancial/events"
  eventsVersion=$( go list -f '{{if not .Indirect}}{{.}}{{end}}' -u -m -mod=mod $eventsLibrary | awk -F'[][]' '{print $2}')
  if [[ $eventsVersion ]]
  then
      echo "$eventsLibrary needs to be updated to the latest release: $eventsVersion"
      echo "Run 'go get -u ""$eventsLibrary""@latest' to resolve this issue"
      exit 1
  fi
fi


# Misspell
if [[ "$OS_NAME" == "linux" ]]; then wget -q -O misspell.tar.gz https://github.com/client9/misspell/releases/download/v0.3.4/misspell_0.3.4_linux_64bit.tar.gz; fi
if [[ "$OS_NAME" == "osx" ]]; then wget -q -O misspell.tar.gz https://github.com/client9/misspell/releases/download/v0.3.4/misspell_0.3.4_mac_64bit.tar.gz; fi
if [[ "$OS_NAME" != "windows" ]]; then
    tar xf misspell.tar.gz
    cp ./misspell ./bin/misspell
    echo "misspell version: "$(./bin/misspell -v)

    ignore=""
    if [ -n "$MISSPELL_IGNORE" ];
    then
        ignore=$MISSPELL_IGNORE
    fi

    for file in "${GOFILES[@]}"
    do
        ./bin/misspell -error -locale US -i "$ignore" $file
    done

    echo "finished misspell check"
fi

# gitleaks
# Right now there are some false positives which make it harder to scan
# See: https://github.com/zricethezav/gitleaks/issues/394
if [[ "$EXPERIMENTAL" == *"gitleaks"* ]]; then
    if [[ "$OS_NAME" == "linux" ]]; then wget -q -O ./bin/gitleaks https://github.com/zricethezav/gitleaks/releases/download/v7.5.0/gitleaks-linux-amd64; fi
    if [[ "$OS_NAME" == "osx" ]]; then wget -q -O ./bin/gitleaks https://github.com/zricethezav/gitleaks/releases/download/v7.5.0/gitleaks-darwin-amd64; fi

    if [[ "$OS_NAME" != "windows" ]]; then
        chmod +x ./bin/gitleaks

        echo "gitleaks version: "$(./bin/gitleaks --version)

        # Scan a few of the most recent commits
        depth=10
        if [ -n "$GITLEAKS_DEPTH" ]; then
            depth=$GITLEAKS_DEPTH
        fi
        ./bin/gitleaks --depth=$depth --path=$(pwd) --verbose
    fi

    echo "finished gitleaks check"
fi

# nancy (vulnerable dependencies)
if [[ "$OS_NAME" == "linux" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.22/nancy-v1.0.22-linux-amd64; fi
if [[ "$OS_NAME" == "osx" ]]; then wget -q -O ./bin/nancy https://github.com/sonatype-nexus-community/nancy/releases/download/v1.0.22/nancy-v1.0.22-darwin-amd64; fi
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
    go list -mod=mod -m all | ./bin/nancy --skip-update-check sleuth --exclude-vulnerability "$ignored"

    echo "" # newline
    echo "finished nancy check"
fi

# golangci-lint
if [[ "$OS_NAME" != "windows" ]]; then
    wget -q -O - -q https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.41.1

    enabled="-E=bodyclose,exhaustive,gocyclo,rowserrcheck"
    if [ -n "$GOLANGCI_LINTERS" ];
    then
        enabled="$enabled"",$GOLANGCI_LINTERS"
    fi

    ./bin/golangci-lint --version
    ./bin/golangci-lint run "$enabled" --verbose --skip-dirs="(admin|client)" --timeout=2m --disable=errcheck

    echo "finished golangci-lint check"
fi

## Clear GOARCH and GOOS for testing...
GOARCH=''
GOOS=''

# Run 'go test'
if [[ "$OS_NAME" == "windows" ]]; then
    # Just run short tests on Windows as we don't have Docker support in tests worked out for the database tests
    go test ./... -race -short -coverprofile=coverage.txt -covermode=atomic
fi
if [[ "$OS_NAME" != "windows" ]]; then
    if [[ "$org" == "moov-io" ]];
    then
        go test ./... -race -coverprofile=coverage.txt -covermode=atomic -count 1
    else
        go test ./... -race -count 1
    fi
fi

echo "finished running Go tests"
