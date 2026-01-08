#!/bin/bash
set -e

BASE_ACT_PATH=/1c_dir/activation
mkdir -p "${BASE_ACT_PATH}"

CURRENT_TIME=$(date +%Y_%m_%d_%H_%M_%S)
LOG_FILE="${BASE_ACT_PATH}/log_${CURRENT_TIME}.log"

touch "${LOG_FILE}"
echo "[INFO] License activation started: $CURRENT_TIME" > "$LOG_FILE"

EMPTY_IB_NAME=EmptyIB_Activation
EMPTY_IB_PATH="${BASE_ACT_PATH}/${EMPTY_IB_NAME}"

if [[ ! -d "$EMPTY_IB_PATH" ]]; then
    /1c_dir/ibcmd infobase create --db-path="$EMPTY_IB_PATH" &>> "$LOG_FILE"
    printf "\nDisableUnsafeActionProtection=.*%s.*\n" "$EMPTY_IB_NAME" >> /1c_conf/conf.cfg
fi

LICENSE_DIR=$(readlink -f /1c_licenses)
chmod -R 777 "$LICENSE_DIR"

Xvfb :99 -screen 0 1920x1080x24 &>> "$LOG_FILE" &
export DISPLAY=:99 #Xvfb DISPLAY = 99

echo "[INFO] Ready to start an empty file infobase..." >> "$LOG_FILE"

ACT_REGPORT=9141
ACT_RANGE=9160:9161
nohup /1c_dir/ibsrv \
  --db-path="$EMPTY_IB_PATH" \
  --name="$EMPTY_IB_NAME" \
  --direct-regport="$ACT_REGPORT" \
  --direct-range="$ACT_RANGE" \
  </dev/null >>"$LOG_FILE" 2>&1 &

SERVER_PID=$!
for _ in {1..30}; do
    netstat -tln | grep "$ACT_REGPORT" && break
    sleep 1
done

echo "[INFO] The server is started successfully (PID=$SERVER_PID). Attaching the thin client..." >> "$LOG_FILE"

ACT_HOST=localhost
nohup /1c_dir/1cv8c ENTERPRISE /S "${ACT_HOST}":"$ACT_REGPORT"/"$EMPTY_IB_NAME" \
  /Execute "${BASE_ACT_PATH}/${COMMUNITY_LICENSE_ACTIVATOR}" \
  /C "login=${DEV_LOGIN};password=${DEV_PASSWORD};agentHost=${ACT_HOST};agentPort=${ACT_REGPORT};acceptLicense=true" \
  /DisableStartupMessages \
  /UseHwLicenses- \
  </dev/null >>"$LOG_FILE" 2>&1 &

  #/DisableStartupDialogs \
  #/SuppressDialogs \

CLIENT_PID=$!
echo "[INFO] Waiting for license activator (PID=$CLIENT_PID)..." >> "$LOG_FILE"

wait "$CLIENT_PID"

chown -R usr1cv8:grp1cv8 "$LICENSE_DIR"
chmod -R 755 "$LICENSE_DIR"

echo "[INFO] Ready to close the elderly started processes." >> "$LOG_FILE"

pkill -2 ibsrv &>> "$LOG_FILE"
pkill -2 Xvfb &>> "$LOG_FILE"

echo "[INFO] License activator finished." >> "$LOG_FILE"