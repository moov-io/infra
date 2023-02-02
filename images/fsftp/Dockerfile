FROM golang:1.20-alpine as builder
RUN apk add -U git
WORKDIR /go/src/github.com/moov-io/fsftp/
ENV CGO_ENABLED=0
COPY main.go main.go
RUN go mod init github.com/moov-io/fsftp
RUN go get -u ./...
RUN go build -o /go/bin/fsftp main.go

FROM scratch
LABEL maintainer="Moov <support@moov.io>"
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/fsftp /bin/fsftp
EXPOSE 2121
ENTRYPOINT ["/bin/fsftp"]
