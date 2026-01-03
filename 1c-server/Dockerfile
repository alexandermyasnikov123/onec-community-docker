FROM ubuntu:22.04
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH
ARG SERVER_COMPONENTS
ARG ONEC_USER

ENV PLATFORM_VERSION=${PLATFORM_VERSION}
ENV PLATFORM_ARCH=${PLATFORM_ARCH}
ENV SERVER_PORT=${SERVER_PORT:-1540}
ENV SERVER_AGENT_PORT=${SERVER_AGENT_PORT:-1541}
ENV ONEC_USER=${ONEC_USER}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgsf-1-114 \
    libglib2.0-0 \
    libgstreamer1.0-0 \
    sudo \
    net-tools \
    language-pack-ru \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

RUN groupadd -g 1001 grp1cv8 && \
    useradd -u 1001 -g grp1cv8 --shell /bin/bash --create-home ${ONEC_USER}

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run \
        --mode unattended \
        --enable-components ${SERVER_COMPONENTS} && \
    rm /tmp/installer.run

RUN mkdir -p /var/1C/1cv8 /var/1C/licenses && \
    chown -R ${ONEC_USER}:grp1cv8 /var/1C && \
    chmod 755 /var/1C/1cv8 && \
    chmod 777 /var/1C/licenses

VOLUME ["/var/1C/licenses"]
VOLUME ["/var/1C/1cv8"]

EXPOSE ${SERVER_PORT} ${SERVER_AGENT_PORT}

RUN echo '#!/bin/bash' > /start-server.sh && \
    echo 'set -e' >> /start-server.sh && \
    echo '' >> /start-server.sh && \
    echo 'exec sudo -u ${ONEC_USER} /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION}/ragent \' >> /start-server.sh && \
    echo '  -debug \' >> /start-server.sh && \
    echo '  -d /var/1C/1cv8 \' >> /start-server.sh && \
    echo '  -port ${SERVER_PORT} \' >> /start-server.sh && \
    echo '  -regport ${SERVER_AGENT_PORT}' >> /start-server.sh && \
    chmod +x /start-server.sh

ENTRYPOINT ["/start-server.sh"]
