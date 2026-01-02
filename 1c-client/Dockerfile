FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ARG PLATFORM_VERSION
ARG PLATFORM_ARCH
ARG CLIENT_COMPONENTS
ARG INSTALLER_LANGUAGE
ARG DISABLE_COMPONENTS

# Установка всех зависимостей
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

# Настройка локали
RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8

# СОЗДАЁМ ПОЛЬЗОВАТЕЛЯ ДЛЯ 1С С ДОМАШНЕЙ ДИРЕКТОРИЕЙ
RUN useradd -m -s /bin/bash -u 1000 -G sudo 1cuser && \
    echo "1cuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/1cuser/.1cv8/1C/1cv8/conf && \
    chown -R 1cuser:1cuser /home/1cuser

# Копируем установщик
COPY /distr/setup-full-${PLATFORM_VERSION}-${PLATFORM_ARCH}.run /tmp/installer.run

# Устанавливаем 1С
RUN chmod +x /tmp/installer.run && \
    /tmp/installer.run \
        --mode unattended \
        --enable-components ${CLIENT_COMPONENTS} && \
    rm /tmp/installer.run

# СОЗДАЁМ СИМЛИНК ДЛЯ ЛИЦЕНЗИЙ
# Клиент будет писать в /home/1cuser/.1cv8/1C/1cv8/conf/
# но через симлинк файлы будут попадать в общий том
RUN mkdir -p /var/shared_licenses && \
    chmod 777 /var/shared_licenses && \
    ln -sf /var/shared_licenses /home/1cuser/.1cv8/1C/1cv8/conf/licenses

# Переключаемся на созданного пользователя
USER 1cuser
WORKDIR /home/1cuser

# Запуск с dbus сессией
CMD ["sh", "-c", "dbus-run-session /opt/1cv8/x86_64/${PLATFORM_VERSION}/1cv8"]
