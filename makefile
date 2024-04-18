PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

.PHONY: check
check:
	EXPERIMENTAL=gitleaks,govulncheck,nilaway,shuffle \
	COVER_THRESHOLD=80.0 \
	GOCYCLO_LIMIT=15 \
	GOLANGCI_FLAGS="--exclude-use-default=false" \
	GOTEST_FLAGS='-test.shuffle=on' \
	PROFILE_GOTEST='yes' \
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
