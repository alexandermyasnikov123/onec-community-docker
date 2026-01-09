FROM ubuntu:22.04 AS base_image
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Основные утилиты и шрифты \
    libfreetype6 \
    libgsf-1-common \
    libfreetype6 \
    libglib2.0-0 \
    libgstreamer1.0-0 \
    net-tools \
    iproute2 \
    gosu \
    language-pack-ru \
    locales \
    ttf-mscorefonts-installer \
    # GUI библиотеки для активации лицензии на сервере :)
    libcups2 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxinerama1 \
    libxrandr2 \
    libatk1.0-0 \
    libgtk-3-0 \
    libwebkit2gtk-4.0-37 \
    libglu1-mesa \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN fc-cache -fv

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8 LANGUAGE=ru_RU:ru LC_ALL=ru_RU.UTF-8

FROM base_image
LABEL authors="Alexander Myasnikov"

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH=x86_64
ARG SERVER_COMPONENTS=client_thin_fib,server,server_admin,ws,liberica_jre,ru

ENV DEV_LOGIN=login DEV_PASSWORD=password

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run --mode unattended --enable-components ${SERVER_COMPONENTS} && \
    rm /tmp/installer.run

RUN ln -s /opt/1cv8/conf /1c_conf && \
    mkdir -p /opt/1cv8/scripts &&  \
    ln -s /opt/1cv8/scripts /1c_scripts && \
    ln -s /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION} /1c_dir && \
    ln -s /var/1C/licenses /1c_licenses && \
    ln -s /1c_dir/ragent 1c_ragent && \
    ln -s /1c_dir/ras 1c_ras

VOLUME /1c_dir /1c_licenses /home/usr1cv8

EXPOSE ${SERVER_PORT} ${SERVER_AGENT_PORT}

ENV COMMUNITY_LICENSE_ACTIVATOR=ActivateCommunity.epf
COPY /${COMMUNITY_LICENSE_ACTIVATOR} /1c_dir/activation/
COPY /1c-server/*.sh /1c_scripts/
RUN chmod +x /1c_scripts/*.sh

ENTRYPOINT ["/1c_scripts/entrypoint.sh"]
