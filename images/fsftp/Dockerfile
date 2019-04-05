FROM golang:1.12-alpine as builder
RUN apk add -U git
WORKDIR /go/src/github.com/goftp
RUN git clone https://github.com/goftp/server.git
WORKDIR /go/src/github.com/goftp/server
ENV CGO_ENABLED=0
RUN go get -u ./...
RUN go build -o /go/bin/fsftp github.com/goftp/server/exampleftpd

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/fsftp /bin/fsftp
EXPOSE 2121
ENTRYPOINT ["/bin/fsftp"]
