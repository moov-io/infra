VERSION := v0.6.2

.PHONY: docker release

docker:
	docker build --pull -t moov/kube-ingress-index:$(VERSION) .
	docker tag moov/kube-ingress-index:$(VERSION) moov/kube-ingress-index:latest

release:
	docker push moov/kube-ingress-index:$(VERSION)
