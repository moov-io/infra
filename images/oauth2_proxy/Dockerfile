FROM golang:1.11-stretch as builder
WORKDIR /go/src/github.com/bitly/
RUN apt-get update && apt-get install -y ca-certificates gcc g++ git make wget
RUN git clone https://github.com/bitly/oauth2_proxy.git
WORKDIR /go/src/github.com/bitly/oauth2_proxy
RUN git checkout tags/v2.2 -b v2.2
RUN git branch --set-upstream-to=origin/master v2.2
RUN git log -n1
RUN CGO_ENABLED=0 go get -u github.com/bitly/oauth2_proxy

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /go/bin/oauth2_proxy /bin/oauth2_proxy
ENTRYPOINT ["/bin/oauth2_proxy"]
