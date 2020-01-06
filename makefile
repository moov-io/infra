PLATFORM=$(shell uname -s | tr '[:upper:]' '[:lower:]')

.PHONY: all
.PHONY: check
check:
	go fmt ./...
	go vet ./...

.PHONY: clean
clean:
	rm -f kubeval

.PHONY: generate kubernetes-mixins
generate: kubernetes-mixins

kubernetes-mixins:
	@go run ./cmd/kubernetes-mixins/

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

.PHONY: test
test: check
# Test our docker images
	@go run ./cmd/dockertest
# Kubeval
ifneq ($(TRAVIS_OS_NAME),osx)
	wget -nc https://github.com/instrumenta/kubeval/releases/download/0.14.0/kubeval-$(PLATFORM)-amd64.tar.gz
	tar -xf kubeval-$(PLATFORM)-amd64.tar.gz kubeval && chmod +x ./kubeval
	find lib/* -type f -name *.yml | grep -v blackbox | grep -v '19-etcd' | grep -v '20-vault' | xargs -n1 -I {} ./kubeval $(shell pwd)/'{}' --strict -v 1.14.7
else
	@echo "Skipping kubeval tests on TravisCI"
endif
