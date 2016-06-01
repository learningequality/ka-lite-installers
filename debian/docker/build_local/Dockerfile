FROM ubuntu

RUN apt-get update && apt-get install -y \
    devscripts \
    python \
	python-pip \
	software-properties-common \
	git \
	wget \
	equivs \
	gdebi

WORKDIR /ka-lite-source-${deb_ver}

COPY ./docker-entrypoint.sh /

#RUN debuild --no-lintian -us -uc
