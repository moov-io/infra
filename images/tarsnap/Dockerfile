FROM debian:stable-slim
LABEL maintainer="Moov <oss@moov.io>"

# Docs: https://www.tarsnap.com/pkg-deb.html

RUN apt-get update -qq && apt-get install -y ca-certificates lsb-release gnupg2 wget
RUN wget https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc

# To verify this key, run:
# gpg --list-packets tarsnap-deb-packaging-key.asc | grep signature

# Import the GPG key directly to /etc/apt/trusted.gpg.d/
RUN gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/tarsnap.gpg --import tarsnap-deb-packaging-key.asc
RUN chmod 644 /etc/apt/trusted.gpg.d/tarsnap.gpg

RUN echo "deb http://pkg.tarsnap.com/deb/$(lsb_release -s -c) ./" | tee -a /etc/apt/sources.list.d/tarsnap.list
RUN apt-get update -qq && apt-get install -y tarsnap

USER backup
RUN tarsnap --version
