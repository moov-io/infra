VERSION := v0.1.0-dev

.PHONY: docker release

docker:
	docker build --pull -t moov/tarsnap:$(VERSION) .
	docker tag moov/tarsnap:$(VERSION) moov/tarsnap:latest

release:
	docker push moov/tarsnap:$(VERSION)
