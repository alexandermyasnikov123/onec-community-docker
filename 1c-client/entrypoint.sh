#!/bin/bash
# entrypoint.sh - минимальный рабочий вариант

# Настройка лицензии - КРИТИЧЕСКИ ВАЖНО
mkdir -p ~/.1cv8/1C/1cv8/conf 2>/dev/null || true

if [ -d "/var/shared_licenses" ] && [ -n "$(ls -A /var/shared_licenses 2>/dev/null)" ]; then
    # Копируем лицензию из общего каталога
    cp -r /var/shared_licenses/* ~/.1cv8/1C/1cv8/conf/ 2>/dev/null || true
else
    # Если лицензии нет - сохраняем симлинк для сохранения после принятия
    ln -sf /var/shared_licenses ~/.1cv8/1C/1cv8/conf 2>/dev/null || true
fi

# Настройка X11
[ -f "$XAUTHORITY" ] && cp "$XAUTHORITY" ~/.Xauthority && chmod 600 ~/.Xauthority

# Путь к 1С
ONEC_PATH="/opt/1cv8/${PLATFORM_ARCH}/${PLATFORM_VERSION}/1cv8s"

# Основной цикл
while true; do
    echo "Запуск 1С..."

    # Запускаем 1cv8s
    $ONEC_PATH &
    MAIN_PID=$!

    # Ждем завершения основного процесса
    wait $MAIN_PID 2>/dev/null || true

    echo "Основной процесс завершен, проверяем дочерние..."

    # Ждем пока есть ЛЮБЫЕ процессы 1cv8 (включая 1cv8c для Конфигуратора)
    while pgrep -f "1cv8" > /dev/null; do
        sleep 2
    done

    echo "Все процессы 1С завершены"

    # Сохраняем лицензию обратно в общий каталог
    if [ -d ~/.1cv8/1C/1cv8/conf ] && [ -n "$(ls -A ~/.1cv8/1C/1cv8/conf 2>/dev/null)" ]; then
        mkdir -p /var/shared_licenses
        cp -r ~/.1cv8/1C/1cv8/conf/* /var/shared_licenses/ 2>/dev/null || true
    fi

    # Если контейнеру послали SIGTERM - выходим
    if [ -f /tmp/stop_requested ]; then
        echo "Завершение по запросу"
        exit 0
    fi

    # Иначе перезапускаем (на случай если 1С упал)
    echo "Перезапуск через 2 секунды..."
    sleep 2
done