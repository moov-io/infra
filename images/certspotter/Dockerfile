FROM golang:1.13-alpine as builder
WORKDIR /go/src/software.sslmate.com/src/
RUN wget -O certspotter.tar.gz https://github.com/SSLMate/certspotter/archive/0.9.tar.gz
RUN tar xf certspotter.tar.gz && mv certspotter-* certspotter
WORKDIR /go/src/software.sslmate.com/src/certspotter/
ENV CGO_ENABLED=0
ENV GO111MODULE=on
RUN go build -o /go/bin/certspotter software.sslmate.com/src/certspotter/cmd/certspotter

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/certspotter /bin/certspotter
ENTRYPOINT ["/bin/certspotter"]
