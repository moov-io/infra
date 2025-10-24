PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

.PHONY: check
check:
	EXPERIMENTAL=gitleaks,nilaway,shuffle,xmlencoderclose \
	COVER_THRESHOLD=25.0 \
	GOCYCLO_LIMIT=15 \
	GOTEST_PARALLEL=8 \
	GOLANGCI_LINTERS="lll" \
	DISABLED_GOLANGCI_LINTERS="lll" \
	GOLANGCI_SKIP_DIR="./not-exist/" \
	GOLANGCI_SKIP_FILES="not_found.go" \
	./go/lint-project.sh

.PHONY: docker
docker:
	go run ./cmd/dockertest

.PHONY: test test-docker
test: check test-docker

test-docker:
	@go run ./cmd/dockertest

test-shell:
	shellcheck ./go/lint-project.sh
