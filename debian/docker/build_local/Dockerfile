FROM ubuntu

RUN apt-get update && apt-get install -y \
    devscripts \
    python \
	python-pip \
	software-properties-common \
	git \
	wget \
	nodejs \
	npm

RUN apt-get update && apt-get install -y \
    equivs \
	gdebi

ENV deb_ver=0.16.6
WORKDIR /ka-lite-source-${deb_ver}

COPY ./docker-entrypoint.sh /