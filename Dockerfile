FROM debian:stretch-slim
RUN apt update; apt install -yq dnsutils; apt-get clean
