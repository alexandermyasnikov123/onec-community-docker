FROM ubuntu:22.04 AS base_image
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

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

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

FROM base_image
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH=x86_64

ARG SERVER_COMPONENTS

ARG ONEC_SERVER_USER=usr1srv
ARG ONEC_USER_GID=1001
ARG ONEC_USER_UID=1001

ENV SERVER_PORT=${SERVER_PORT:-1540}
ENV SERVER_AGENT_PORT=${SERVER_AGENT_PORT:-1541}

RUN groupadd -g ${ONEC_USER_GID} grp1cv8 && \
    useradd -u ${ONEC_USER_UID} -g grp1cv8 --shell /bin/bash --create-home ${ONEC_SERVER_USER}

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run --mode unattended --enable-components ${SERVER_COMPONENTS} && \
    rm /tmp/installer.run

RUN mkdir -p /opt/1cv8
RUN ln -s /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION} /opt/1cv8/current
RUN ln -s /opt/1cv8/current/ragent 1c_ragent

VOLUME /var/1C/licences
VOLUME /home/${ONEC_SERVER_USER}/.1cv8

EXPOSE ${SERVER_PORT} ${SERVER_AGENT_PORT}

COPY /1c-server/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["sh", "-c", "./entrypoint.sh"]
