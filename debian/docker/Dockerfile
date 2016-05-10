FROM ubuntu
RUN apt-get update && apt-get install -y \
    devscripts \
    python \
	python-pip \
	software-properties-common
RUN add-apt-repository -sy ppa:learningequality/ka-lite-proposed && \
    apt-get update && \
	apt-get build-dep -y ka-lite && \
	apt-get source ka-lite
ENV deb_ver=0.16.6
RUN pip install --pre ka-lite-static -d . && \
    cd /ka-lite-source-* && \
    uupdate --no-symlink -v $deb_ver /ka-lite-static-*.tar.gz
WORKDIR /ka-lite-source-${deb_ver}
RUN debuild --no-lintian -us -uc

COPY ./docker-entrypoint.sh /