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

.PHONY: test test-docker test-kubeval test-mysql
test: check test-docker test-kubeval test-promtool-configmap

test-docker:
	@go run ./cmd/dockertest

test-kubeval:
ifneq ($(TRAVIS_OS_NAME),osx)
	wget -nc https://github.com/instrumenta/kubeval/releases/download/0.14.0/kubeval-$(PLATFORM)-amd64.tar.gz
	tar -xf kubeval-$(PLATFORM)-amd64.tar.gz kubeval && chmod +x ./kubeval
	find lib/* -type f -name *.yml | grep -v blackbox | grep -v '19-etcd' | grep -v '20-vault' | xargs -n1 -I {} ./kubeval $(shell pwd)/'{}' --strict -v 1.14.7
else
	@echo "Skipping kubeval tests on TravisCI"
endif

test-promtool-configmap:
	promtool-configmap --version
# Handcrafted files
	promtool-configmap envs/prod/infra/14-prometheus.yml
	promtool-configmap envs/prod/infra/14-prometheus-rules.yml
# Generated files
	promtool-configmap envs/prod/infra/14-prometheus-kubernetes-mixin-alerts.yml
	promtool-configmap envs/prod/infra/14-prometheus-kubernetes-mixin-rules.yml

test-mysql:
	@for dir in $(shell ls -1 ./tests/); do \
		cd ./tests/"$$dir" && ./test.sh && cd ../; \
	done
