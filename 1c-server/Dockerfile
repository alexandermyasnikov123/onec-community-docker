FROM ubuntu:22.04 AS base_image
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgsf-1-114 \
    libglib2.0-0 \
    libgstreamer1.0-0 \
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

ARG SERVER_COMPONENTS=server,server_admin,ws,liberica_jre,ru

ARG ONEC_USER_GID=1001
ARG ONEC_USER_UID=1001
ARG ONEC_USER_NAME=usr1cclnt

RUN groupadd -r grp1cv8 --gid ${ONEC_USER_GID} && \
    useradd -r -g grp1cv8 --uid ${ONEC_USER_UID} --home-dir /home/${ONEC_USER_NAME} --shell /bin/bash ${ONEC_USER_NAME} && \
    mkdir -p /var/log/1C /home/${ONEC_USER_NAME}/.1cv8/1C/1cv8/conf /opt/1cv8/current/conf && \
    chown -R ${ONEC_USER_NAME}:grp1cv8 /var/log/1C /home/${ONEC_USER_NAME}

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run --mode unattended --enable-components ${SERVER_COMPONENTS} && \
    rm /tmp/installer.run

RUN ln -s /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION} /1c_dir
RUN ln -s /1c_dir/ragent 1c_ragent

VOLUME /1c_dir/conf
VOLUME /home/${ONEC_USER_NAME}

EXPOSE ${SERVER_PORT} ${SERVER_AGENT_PORT}

COPY /1c-server/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${ONEC_USER_NAME}

ENTRYPOINT ["/entrypoint.sh"]
