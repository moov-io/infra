FROM alpine:latest as builder
RUN apk add -U ca-certificates wget
RUN wget -O oauth2_proxy.tar.gz https://github.com/bitly/oauth2_proxy/releases/download/v2.2/oauth2_proxy-2.2.0.linux-amd64.go1.8.1.tar.gz
RUN tar xf oauth2_proxy.tar.gz

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /oauth2_proxy-*/oauth2_proxy /bin/oauth2_proxy
ENTRYPOINT ["/bin/oauth2_proxy"]
