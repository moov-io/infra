FROM golang:1.13-alpine as builder

# Pull down Banno/kube-ingress-index source code
RUN mkdir -p /go/src/github.com/Banno/kube-ingress-index
WORKDIR /tmp/
RUN wget -O code.tar.gz https://github.com/Banno/kube-ingress-index/archive/0.6.2.tar.gz
RUN tar xf code.tar.gz && cp -r kube-ingress-index-0.6.2/* /go/src/github.com/Banno/kube-ingress-index/

# Setup and build the binary
WORKDIR /go/src/github.com/Banno/kube-ingress-index
RUN adduser -D -g '' --shell /bin/false moov
RUN CGO_ENABLED=0 go build -o ./bin/kube-ingress-index
USER moov

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/src/github.com/Banno/kube-ingress-index/bin/kube-ingress-index /bin/kube-ingress-index
COPY --from=builder /etc/passwd /etc/passwd
USER moov
EXPOSE 8080
EXPOSE 9090
ENTRYPOINT ["/bin/kube-ingress-index"]
