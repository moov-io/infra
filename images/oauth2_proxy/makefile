VERSION := v2.2-moov2-dev

.PHONY: docker release

docker:
	docker build -t moov/oauth2_proxy:$(VERSION) .
	docker tag moov/oauth2_proxy:$(VERSION) moov/oauth2_proxy:latest

release:
	docker push moov/oauth2_proxy:$(VERSION)
