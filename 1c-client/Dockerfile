FROM ubuntu:22.04 AS base_image
LABEL authors="Alexander Myasnikov"

ENV DEBIAN_FRONTEND=noninteractive

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
    # Различные утилиты
    gosu \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8 LANGUAGE=ru_RU:ru LC_ALL=ru_RU.UTF-8

FROM base_image
LABEL authors="Alexander Myasnikov"

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH=x86_64

ARG CLIENT_COMPONENTS=client_full,client_thin_fib,desktop_icons,ru

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN groupadd -r grp1cv8 --gid 1001 && \
    useradd -r -g grp1cv8 --uid 1001 --home-dir /home/usr1cv8 --shell /bin/bash usr1cv8 && \
    mkdir -p /home/usr1cv8/.1cv8 && \
    chown -R usr1cv8:grp1cv8 /home/usr1cv8

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run --mode unattended --enable-components ${CLIENT_COMPONENTS} && \
    rm /tmp/installer.run

RUN ln -s /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION} /1c_dir && \
    mkdir -p /opt/1cv8/scripts &&  \
    ln -s /opt/1cv8/scripts /1c_scripts

COPY /1c-client/*.sh /1c_scripts/
RUN chmod +x /1c_scripts/*.sh

VOLUME /home/usr1cv8

ENTRYPOINT ["/1c_scripts/entrypoint.sh"]
CMD ["/1c_scripts/run_launcher.sh"]
