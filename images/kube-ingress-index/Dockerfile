FROM golang:1.13-alpine as builder
WORKDIR /tmp/
RUN wget https://github.com/Banno/kube-ingress-index/releases/download/0.6.2/kube-ingress-index_0.6.2_linux_amd64.tar.gz
RUN tar xf kube-ingress-index_0.6.2_linux_amd64.tar.gz && cp kube-ingress-index /go/bin/kube-ingress-index

# Setup and build the binary
RUN adduser -D -g '' --shell /bin/false moov
USER moov

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/kube-ingress-index /bin/kube-ingress-index
COPY --from=builder /etc/passwd /etc/passwd
USER moov
EXPOSE 8080
EXPOSE 9090
ENTRYPOINT ["/bin/kube-ingress-index"]
