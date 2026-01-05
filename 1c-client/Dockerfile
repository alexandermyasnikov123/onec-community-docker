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
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

FROM base_image
LABEL authors="Alexander Myasnikov"

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH=x86_64

ARG CLIENT_COMPONENTS=client_full,client_thin_fib,desktop_icons,ru

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

ARG ONEC_USER_GID=1001
ARG ONEC_USER_UID=1001
ARG ONEC_USER_NAME=usr1cclnt

RUN groupadd -r grp1cv8 --gid ${ONEC_USER_GID} && \
    useradd -r -g grp1cv8 --uid ${ONEC_USER_UID} --home-dir /home/${ONEC_USER_NAME} --shell /bin/bash ${ONEC_USER_NAME} && \
    mkdir -p /home/${ONEC_USER_NAME}/.1cv8 && \
    chown -R ${ONEC_USER_NAME}:grp1cv8 /home/${ONEC_USER_NAME}

COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run --mode unattended --enable-components ${CLIENT_COMPONENTS} && \
    rm /tmp/installer.run

RUN ln -s /opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION} /1c_dir

COPY /1c-client/entrypoint.sh /1c_dir/
RUN chmod +x /1c_dir/entrypoint.sh

VOLUME /home/${ONEC_USER_NAME}

USER ${ONEC_USER_NAME}
WORKDIR /home/${ONEC_USER_NAME}

ENTRYPOINT ["/1c_dir/entrypoint.sh"]
CMD ["/1c_dir/1cv8s"]
