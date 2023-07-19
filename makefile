PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

.PHONY: check
check:
	EXPERIMENTAL=gitleaks,govulncheck,shuffle \
	COVER_THRESHOLD=80.0 \
	GOCYCLO_LIMIT=15 \
	GOLANGCI_FLAGS="--exclude-use-default=false" \
	GOTEST_FLAGS='-test.shuffle=on' \
	PROFILE_GOTEST='yes' \
	./go/lint-project.sh

.PHONY: clean
clean:
	rm -f kubeval

# From https://github.com/genuinetools/img
.PHONY: AUTHORS
AUTHORS:
	@$(file >$@,# This file lists all individuals having contributed content to the repository.)
	@$(file >>$@,# For how it is generated, see `make AUTHORS`.)
	@echo "$(shell git log --format='\n%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf)" >> $@

.PHONY: release
release: AUTHORS

.PHONY: docker
docker:
	go run ./cmd/dockertest

.PHONY: install
install:
	@mkdir -p ./bin/
ifeq ($(PLATFORM),linux)
	wget -O prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.linux-amd64.tar.gz
	wget -O ./bin/promtool-configmap https://github.com/adamdecaf/promtool-configmap/releases/download/v0.3.0/promtool-configmap-linux
endif
ifeq ($(PLATFORM),darwin)
	wget -O prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.darwin-amd64.tar.gz
	wget -O ./bin/promtool-configmap https://github.com/adamdecaf/promtool-configmap/releases/download/v0.3.0/promtool-configmap-macos
endif
ifneq ($(OS),Windows_NT)
	tar xf prometheus.tar.gz && cp -r ./prometheus-*/promtool ./bin/promtool
	rm -rf prometheus-2.15.2.darwin-amd64/ prometheus.tar.gz
	chmod +x ./bin/promtool-configmap
endif

.PHONY: test test-docker test-kubeval test-mysql
test: check test-docker test-kubeval

test-docker:
	@go run ./cmd/dockertest

test-kubeval:
ifneq ($(OS),Windows_NT)
	wget -nc https://github.com/instrumenta/kubeval/releases/download/0.15.0/kubeval-$(PLATFORM)-amd64.tar.gz
	tar -xf kubeval-$(PLATFORM)-amd64.tar.gz kubeval && chmod +x ./kubeval
	find lib/* -type f -name *.yml | grep -v blackbox | grep -v '19-etcd' | grep -v '20-vault' | xargs -n1 -I {} ./kubeval $(shell pwd)/'{}' --strict -v 1.18.1
else
	@echo "Skipping kubeval tests on TravisCI"
endif

test-shell:
	shellcheck ./go/lint-project.sh

test-mysql:
	@for dir in $(shell ls -1 ./tests/); do \
		cd ./tests/"$$dir" && ./test.sh && cd ../; \
	done
