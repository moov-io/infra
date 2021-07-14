FROM debian:buster-20210621-slim
LABEL maintainer="Moov <support@moov.io>"

# Docs: https://www.tarsnap.com/pkg-deb.html

RUN apt-get update -qq && apt-get install -y ca-certificates lsb-release gnupg2 wget
RUN wget https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc

# To verify this key, run:
# gpg --list-packets tarsnap-deb-packaging-key.asc | grep signature

RUN apt-key add tarsnap-deb-packaging-key.asc
RUN echo "deb http://pkg.tarsnap.com/deb/$(lsb_release -s -c) ./" | tee -a /etc/apt/sources.list.d/tarsnap.list
RUN apt-get update -qq && apt-get install -y tarsnap # tarsnap-archive-keyring # libssl

USER backup
RUN tarsnap --version
