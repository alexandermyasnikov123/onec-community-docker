FROM ubuntu:22.04
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH
ARG CLIENT_COMPONENTS
ARG ONEC_USER

ENV PLATFORM_VERSION=${PLATFORM_VERSION}
ENV PLATFORM_ARCH=${PLATFORM_ARCH}
ENV ONEC_USER=${ONEC_USER}
ENV HOME=/home/${ONEC_USER}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # GTK3 и базовые графические библиотеки
    libgtk-3-0 \
    libgtk2.0-0 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    # GTK модули
    libcanberra-gtk3-module \
    libcanberra-gtk-module \
    packagekit-gtk3-module \
    # Accessibility bus
    at-spi2-core \
    # OpenGL
    libglu1-mesa \
    mesa-utils \
    freeglut3 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglapi-mesa \
    # Аудио/видео
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    gstreamer1.0-plugins-good \
    # Шрифты
    fonts-dejavu \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    ttf-mscorefonts-installer \
    # X11
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    xauth \
    # Сеть
    iproute2 \
    iputils-ping \
    curl \
    ca-certificates \
    # Доп. библиотеки 1С
    libwebkit2gtk-4.0-37 \
    libatk-bridge2.0-0 \
    libcups2 \
    libpango-1.0-0 \
    # Локализация
    language-pack-ru \
    locales \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

RUN useradd -m -s /bin/bash -u 1000 -G sudo ${ONEC_USER} && \
    echo "${ONEC_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /home/${ONEC_USER}/1C_Workdir && \
    mkdir -p /var/shared_licenses && \
    chown -R ${ONEC_USER}:${ONEC_USER} /home/${ONEC_USER} && \
    chmod 755 /home/${ONEC_USER} && \
    chmod 777 /var/shared_licenses

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run \
        --mode unattended \
        --enable-components ${CLIENT_COMPONENTS} && \
    rm /tmp/installer.run

VOLUME ["/var/shared_licenses"]
VOLUME ["/home/${ONEC_USER}"]

RUN echo '#!/bin/bash' > /start-client.sh && \
    echo 'set -e' >> /start-client.sh && \
    echo 'mkdir -p ~/.1cv8/1C/1cv8 2>/dev/null || true' >> /start-client.sh && \
    echo 'ln -sf /var/shared_licenses ~/.1cv8/1C/1cv8/conf 2>/dev/null || true' >> /start-client.sh && \
    echo 'exec /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION}/1cv8' >> /start-client.sh && \
    chmod +x /start-client.sh

USER ${ONEC_USER}
WORKDIR /home/${ONEC_USER}/1C_Workdir

ENTRYPOINT ["/start-client.sh"]
