.PHONY: check
check:
	go fmt ./...
	go vet ./...

.PHONE: generate kubernetes-mixins
generate: kubernetes-mixins

kubernetes-mixins:
	@go run ./cmd/kubernetes-mixins/

# From https://github.com/genuinetools/img
.PHONY: AUTHORS
AUTHORS:
	@$(file >$@,# This file lists all individuals having contributed content to the repository.)
	@$(file >>$@,# For how it is generated, see `make AUTHORS`.)
	@echo "$(shell git log --format='\n%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf)" >> $@

release: AUTHORS

.PHONY: test
test: check
# Test our docker images
	@go run ./cmd/dockertest
