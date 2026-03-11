FROM debian:12

COPY ./app /app
WORKDIR /app

RUN apt-get update \
    && apt-get install -y \
        curl \
        wget \
        cron \
        git \
        cmake \
        build-essential \
        speedtest-cli \
    && git clone https://github.com/WhiteCells/lookbusy.git \
    && cd lookbusy \
    && chmod +x ./configure \
    && ./configure \
    && make \
    && make install \
    && cd /app \
    && rm -rf lookbusy \
    && chmod +x /app/*.sh \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/app/docker-entrypoint.sh"]

USER root