#!/bin/sh
set -e

# Обработка сигналов для graceful shutdown
cleanup() {
    # Передаём сигнал всем процессам в группе
    kill -TERM 0 2>/dev/null
    exit 0
}
trap cleanup TERM INT

# Запуск команды
"$@" &

# Ожидаем основной процесс
wait $!

# Ждём все дочерние процессы
while [ -n "$(pgrep -P $$)" ]; do
    wait -n 2>/dev/null || sleep 1
done