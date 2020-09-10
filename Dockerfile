FROM stellar/base:latest

MAINTAINER Bartek Nowotarski <bartek@stellar.org>

ENV STELLAR_CORE_VERSION 12.4.0-1170-c47415d4
ENV HORIZON_VERSION 1.0.0

EXPOSE 5432
EXPOSE 8000
EXPOSE 11625
EXPOSE 11626

ADD dependencies /
RUN ["chmod", "+x", "dependencies"]
RUN /dependencies

ADD install /
RUN ["chmod", "+x", "install"]
RUN /install

RUN ["mkdir", "-p", "/opt/stellar"]
RUN ["touch", "/opt/stellar/.docker-ephemeral"]

RUN useradd --uid 10011001 --home-dir /home/stellar --no-log-init stellar \
    && mkdir -p /home/stellar \
    && chown -R stellar:stellar /home/stellar

RUN ["ln", "-s", "/opt/stellar", "/stellar"]
RUN ["ln", "-s", "/opt/stellar/core/etc/stellar-core.cfg", "/stellar-core.cfg"]
RUN ["ln", "-s", "/opt/stellar/horizon/etc/horizon.env", "/horizon.env"]
ADD common /opt/stellar-default/common
ADD pubnet /opt/stellar-default/pubnet
ADD testnet /opt/stellar-default/testnet
ADD standalone /opt/stellar-default/standalone

# Install s3cmd and its python dependencies (the executable will be /s3cmd/s3cmd)
RUN apt-get install -y python-dateutil \
    && wget -O s3cmd.tar.gz https://github.com/s3tools/s3cmd/releases/download/v2.1.0/s3cmd-2.1.0.tar.gz \
    && tar -zxvf s3cmd.tar.gz \
    && mv s3cmd-2.1.0 s3cmd

ADD pinetwork/.s3cfg /root/.s3cfg


ADD start /
RUN ["chmod", "+x", "start"]

ENTRYPOINT ["/init", "--", "/start" ]
