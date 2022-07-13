VERSION := v0.2.1

.PHONY: docker release

docker:
	docker build --pull -t moov/fsftp:$(VERSION) .
	docker tag moov/fsftp:$(VERSION) moov/fsftp:latest

release:
	docker push moov/fsftp:$(VERSION)
