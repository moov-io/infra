VERSION := v0.3.0

.PHONY: docker release

docker:
	docker build --pull -t moov/infra-idx:$(VERSION) .
	docker tag moov/infra-idx:$(VERSION) moov/infra-idx:latest

.PHONY: run
run:
	mkdir -p ./nginx/cache/ ./nginx/run/
	docker run --read-only -p 8080:8080 -v $(shell pwd)/nginx/cache/:/var/cache/nginx -v $(shell pwd)/nginx/run/:/var/run moov/infra-idx:$(VERSION)

release:
	docker push moov/infra-idx:$(VERSION)
