#!/bin/bash
set -e

gitleaks_version=8.17.0
golangci_version=latest
sqlvet_version=v1.1.5

# Set these to any non-blank value to disable the linter
disable_golangci=""
if [[ "$SKIP_GOLANGCI" != "" ]];
then
    disable_golangci="$SKIP_GOLANGCI"
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
            echo "DEBUG: formatting $file with gofmt"

            test -z $(gofmt -s -w $file)
            if [[ $? != 0 ]];
            then
                echo "ERROR: problem rewriting $file"
                exit 1;
            fi
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
if [[ "$DISABLE_GORACE" != "" ]];
then
    GORACE=''
fi

# Verify no retracted module versions are in the build
retracted_mods=($(go list -m -u all | grep retracted | cut -f1 -d' '))
skip_modules=(
    "github.com/moby/sys/user"
)
for dep in "${retracted_mods[@]}"
do
    # Check if the project actually uses this mod
    if go mod why "$dep" | grep -q "module does not need package";
    then
        echo "INFO: $dep is retracted, but not used in this project"
    else
        # Check if the module is in skip_modules
        skip=false
        for skip_mod in "${skip_modules[@]}"
        do
            if [ "$dep" = "$skip_mod" ]; then
                skip=true
                break
            fi
        done

        if [ "$skip" = true ]; then
            echo "INFO: $dep is retracted but in skip list, ignoring"
        else
            echo "ERROR: $dep needs to be updated, current version is retracted"
            go list -m -u -json "$dep"
            exit 1
        fi
    fi
done

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

    # Find directories and optionally exclude one
    if [ -n "$GITLEAKS_EXCLUDE" ]; then
        dirs=($(find . -mindepth 1 -type d | sort -u | grep -v ".git"))
        dirs=($(printf "%s\n" "${dirs[@]}" | grep -v "$GITLEAKS_EXCLUDE"))

        for dir in "${dirs[@]}"; do
            echo "Running gitleaks on $dir"
            ./bin/gitleaks detect --no-git --verbose --no-banner --source "$dir"
        done
    else
        ./bin/gitleaks detect --no-git --verbose
    fi

    echo "FINISHED gitleaks check"
fi

## Run govulncheck which parses the compiled/used code for known vulnerabilities.
run_govulncheck=true
if [[ "$DISABLE_GOVULNCHECK" != "" ]]; then
    run_govulncheck=false
fi
if [[ "$SKIP_LINTERS" != "" ]]; then
    run_govulncheck=false
fi
if [[ "$run_govulncheck" == "true" ]]; then
    echo "STARTING govulncheck check"

    # Install the latest govulncheck release
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
        "$bin" -test ./...
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

run_xmlencoderclose=true
if [[ "$DISABLE_XMLENCODERCLOSE" != "" ]]; then
    run_xmlencoderclose=false
fi
if [[ "$SKIP_LINTERS" != "" ]]; then
    run_xmlencoderclose=false
fi
if [[ "$run_xmlencoderclose" == "true" ]]; then
    echo "STARTING xmlencoderclose check"

    # Install xmlencoderclose
    go install github.com/adamdecaf/xmlencoderclose@latest

    # Find the linter
    bin=""
    if which -s xmlencoderclose > /dev/null;
    then
        bin=$(which xmlencoderclose 2>&1 | head -n1)
    fi
    # Public Github runners path
    actions_path="/home/runner/go/bin/xmlencoderclose"
    if [[ -f "$actions_path" ]];
    then
        bin="$actions_path"
    fi
    # Moov hosted runner paths
    actions_path="/home/actions/bin/xmlencoderclose"
    if [[ -f "$actions_path" ]];
    then
        bin="$actions_path"
    fi

    # Run xmlencoderclose
    if [[ "$bin" != "" ]];
    then
        "$bin" -test ./...
        echo "FINISHED xmlencoderclose check"
    else
        echo "Can't find xmlencoderclose..."
    fi
fi

if [[ "$EXPERIMENTAL" == *"nilaway"* ]];
then
    # nilaway can deliver false positives so it's not currently allowed inside of golangci-lint,
    # however this linter is useful so we offer it.
    #
    # https://github.com/golangci/golangci-lint/issues/4045
    echo "STARTING nilaway check"

    # Install nilaway
    go install go.uber.org/nilaway/cmd/nilaway@latest

    # Find nilaway on PATH
    bin=""
    if which -s nilaway > /dev/null;
    then
        bin=$(which nilaway 2>&1 | head -n1)
    fi
    # Public Github runners path
    actions_path="/home/runner/go/bin/nilaway"
    if [[ -f "$actions_path" ]];
    then
        bin="$actions_path"
    fi
    # Moov hosted runner paths
    actions_path="/home/actions/bin/nilaway"
    if [[ -f "$actions_path" ]];
    then
        bin="$actions_path"
    fi

    # Run nilaway
    if [[ "$bin" != "" ]];
    then
        "$bin" -test=false ./...
        echo "FINISHED nilaway check"
    fi
fi

# golangci-lint
if [[ "$org" == "moov-io" ]];
then
    STRICT_GOLANGCI_LINTERS=${STRICT_GOLANGCI_LINTERS:="yes"}
fi
if [[ "$SKIP_LINTERS" != "" ]]; then
    disable_golangci=true
fi
if [[ "$OS_NAME" != "windows" ]]; then
    if [[ "$disable_golangci" != "" ]];
    then
        echo "SKIPPING golangci-lint"
    else
        echo "STARTING golangci-lint checks"

        # Download golangci-lint
        wget -q -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s "$golangci_version"

        ./bin/golangci-lint version

        # Create a temporary filepath for the config file
        configFilepath=$(mktemp -d)"/config.yml"
        cat <<EOF > "$configFilepath"
version: "2"
run:
  tests: false
  go: "$GO_VERSION"

linters:
  default: none
  enable:
    - forbidigo
  exclusions:
    generated: lax
    presets:
      - comments
      - common-false-positives
      - legacy
      - std-error-handling
    paths:
      - cmd/*
      - admin
      - client
      - docs
      - examples
      - scripts
      - pkg/test/fixtures
EOF
        # Allow skipping one directory from checks
        if [[ "$GOLANGCI_SKIP_DIR" != "" ]];
        then
            echo "      - ""$GOLANGCI_SKIP_DIR" >> "$configFilepath"
        fi

        cat <<EOF >> "$configFilepath"
  settings:
    forbidigo:
      analyze-types: true
      forbid:
        - pkg: ^math/rand$
        - pkg: ^plugin$
        - pattern: ^panic$
        - pattern: .*\.Call.*$
          pkg: reflect
EOF
        # Add some specific overrides
        if [[ "$GOLANGCI_ALLOW_PRINT" != "yes" ]];
        then
            echo "        - pattern: ^fmt\.Print.*$" >> "$configFilepath"
        fi

        # Run golangci-lint over non-test code first with forbidigo
        if [[ "$SKIP_FORBIDIGO" != "yes" ]];
        then
            ./bin/golangci-lint $GOLANGCI_FLAGS run --config="$configFilepath" --timeout=5m --verbose $GOLANGCI_TAGS
        fi

        echo "======"

        # Create a temporary filepath for the config file
        configFilepath=$(mktemp -d)"/config.yml"

        # TODO(adam): re-add unused when they fix some bugs
        default_linters="asciicheck,bidichk,bodyclose,durationcheck,exhaustive,fatcontext,forcetypeassert,gosec,misspell,nolintlint,protogetter,rowserrcheck,sqlclosecheck,testifylint,wastedassign"
        enabled="$default_linters"

        if [ -n "$GOLANGCI_LINTERS" ]; then
            # Append additional linters
            enabled="$enabled,$GOLANGCI_LINTERS"
        fi

        # If SET_GOLANGCI_LINTERS is set, it completely replaces the current set
        if [ -n "$SET_GOLANGCI_LINTERS" ]; then
            enabled="$SET_GOLANGCI_LINTERS"
        fi

        # Add strict linters if STRICT_GOLANGCI_LINTERS is set to "yes"
        if [[ "$STRICT_GOLANGCI_LINTERS" == "yes" ]]; then
            enabled="$enabled,dupword,exptostd,gocheckcompilerdirectives,iface,mirror,nilnesserr,sloglint,testableexamples,usetesting"
        fi

        # Create the config file with the determined linters
        cat <<EOF > "$configFilepath"
version: "2"
run:
  tests: false
  go: "$GO_VERSION"
linters:
  default: none
  settings:
    gosec:
      excludes:
        - G104 # Audit errors not checked
        - G304 # File path provided as taint input
        - G404 # Insecure random number source (rand)
  enable:
    - $(echo $enabled | sed 's/,/\n    - /g')
EOF

        cat <<EOF >> "$configFilepath"
  disable:
    - depguard
    - errcheck
    - forbidigo
EOF
        if [[ "$DISABLED_GOLANGCI_LINTERS" != "" ]];
        then
            cat <<EOF >> "$configFilepath"
    - $(echo "$DISABLED_GOLANGCI_LINTERS" | sed 's/,/\n    - /g')
EOF
        fi

        cat <<EOF >> "$configFilepath"
  exclusions:
    paths:
      - admin
      - client
      - pkg/test/fixtures
EOF
        if [[ "$GOLANGCI_SKIP_DIR" != "" ]];
        then
            echo "      - ""$GOLANGCI_SKIP_DIR" >> "$configFilepath"
        fi
        if [[ "$GOLANGCI_SKIP_FILES" != "" ]];
        then
            echo "      - ""$GOLANGCI_SKIP_FILES" >> "$configFilepath"
        fi

        ./bin/golangci-lint $GOLANGCI_FLAGS run --config="$configFilepath" --verbose --timeout=5m $GOLANGCI_TAGS

        echo "FINISHED golangci-lint checks"

        # Cleanup
        rm -f configFilepath
    fi
fi

if [[ "$SKIP_TESTS" == "yes" ]];
then
    echo "SKIPPING Go tests from env var"
    exit 0;
fi

if [[ "$VENDOR_FOR_TESTS" == "yes" ]];
then
    echo "Vendoring deps before running tests"
    go mod tidy
    go mod vendor
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
coveragePath=$(mktemp -d)"/coverage.txt"

# Find "gotest" or "go test"
GOTEST=$(which go)" test"
if which -s gotest > /dev/null;
then
    GOTEST=$(which gotest 2>&1 | head -n1)
fi

# Run 'go test'
if [[ "$OS_NAME" == "windows" ]]; then
    # Just run short tests on Windows as we don't have Docker support in tests worked out for the database tests
    $GOTEST $GOTAGS "$gotest_packages" "$GORACE" -short -coverprofile="$coveragePath" -covermode=atomic $GOTEST_FLAGS
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
        $GOTEST $GOTAGS "$gotest_packages" "$GORACE" -count 1 $GOTEST_FLAGS
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

                $GOTEST $GOTAGS "$pkg" "$GORACE" \
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
            $GOTEST $GOTAGS "$gotest_packages" "$GORACE" -coverprofile="$coveragePath" -covermode=atomic -count 1 $GOTEST_FLAGS
        fi
    fi
fi

# Run Go Tests on submodules
if [[ "$SKIP_SUBMODULE_TESTS" == "" ]];
then
    submodules=$(find . -mindepth 2 -name go.mod)
    if [ -n "$submodules" ]; then
        echo "Testing Submodules..."

        for mod_file in $submodules; do
            dir=$(dirname "$mod_file")
            (cd "$dir" && $GOTEST $GOTAGS "$gotest_packages" "$GORACE" && cd -)
        done
    fi
fi

# Verify Code Coverage Threshold
if [[ "$COVER_THRESHOLD" != "" && "$COVER_THRESHOLD" != "disabled" ]]; then
    if [[ -f "$coveragePath" && "$PROFILE_GOTEST" != "yes" ]];
    then
        # Ignore test directories in coverage analysis
        cat "$coveragePath" | grep -v -E "/client/" | grep -v -E "/pkg*/*test" | grep -v -E "/internal*/*test" | grep -v -E "/examples/" | grep -v -E "/gen/"  > coverage.txt
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
