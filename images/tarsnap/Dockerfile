FROM debian:jessie

# Docs: https://www.tarsnap.com/pkg-deb.html

RUN apt-get update -qq && apt-get install -y ca-certificates wget
RUN wget https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc

# To verify this key, run:
# gpg --list-packets tarsnap-deb-packaging-key.asc | grep signature

RUN apt-key add tarsnap-deb-packaging-key.asc
RUN echo "deb http://pkg.tarsnap.com/deb/jessie ./" | tee -a /etc/apt/sources.list.d/tarsnap.list
RUN apt-get update -qq && apt-get install -y tarsnap

USER backup
RUN tarsnap --version
