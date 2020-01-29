VERSION := v0.9

.PHONY: docker release

docker:
	docker build --pull -t moov/certspotter:$(VERSION) .
	docker tag moov/certspotter:$(VERSION) moov/certspotter:latest

release:
	docker push moov/certspotter:$(VERSION)
