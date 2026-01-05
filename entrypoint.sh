#!/bin/bash
# start-1c.sh

# Проверяем, запущен ли X11 сервер
if [ -z "$DISPLAY" ]; then
    echo "DISPLAY не установлен. Убедитесь, что X11 сервер запущен."
    exit 1
fi

# Разрешаем доступ для Docker
xhost +local:docker

# Создаем .xauth файл
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Запускаем контейнер
docker compose up

# Запускаем 1С клиент
# docker exec -it 1c-thick-client /opt/1C/v8.3/x86_64/1cv8