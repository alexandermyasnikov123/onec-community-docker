#!/bin/bash
set -euo pipefail

echo "[INFO] License activation started: $CURRENT_SERVICE_UP_TIME"

EMPTY_IB_NAME=EmptyIB_Activation
EMPTY_IB_PATH="${BASE_ACT_PATH}/${EMPTY_IB_NAME}"

if [[ ! -d "$EMPTY_IB_PATH" ]]; then
    echo "[INFO] Creating empty infobase: $EMPTY_IB_PATH"
    /1c_dir/ibcmd infobase create --db-path="$EMPTY_IB_PATH"
    printf "\nDisableUnsafeActionProtection=.*%s.*\n" "$EMPTY_IB_NAME" >> /1c_conf/conf.cfg
else
    echo "[INFO] Infobase already exists: $EMPTY_IB_PATH"
fi

LICENSE_DIR=$(readlink -f /1c_licenses)
chmod -R 777 "$LICENSE_DIR"

export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 &
XVFB_PID=$!

for _ in {1..5}; do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        break
    fi
    echo "[INFO] Waiting for Xvfb to start..."
    sleep 1
done

cleanup() {
    echo "[INFO] Cleaning up processes..."
    kill -15 "${CLIENT_PID:-0}" "${SERVER_PID:-0}" "$XVFB_PID" 2>/dev/null || true
    wait "${CLIENT_PID:-}" "${SERVER_PID:-}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

ACT_REGPORT=9141
ACT_RANGE=9160:9161
nohup /1c_dir/ibsrv \
  --db-path="$EMPTY_IB_PATH" \
  --name="$EMPTY_IB_NAME" \
  --direct-regport="$ACT_REGPORT" \
  --direct-range="$ACT_RANGE" \
  </dev/null &

SERVER_PID=$!
echo "[INFO] The server is started successfully (PID=$SERVER_PID). Attaching the thin client..."

for _ in {1..30}; do
    if netstat -tln | grep -q "$ACT_REGPORT"; then
        echo "[INFO] Server is listening on port $ACT_REGPORT"
        break
    fi
    sleep 1
done

ACT_HOST=localhost
nohup /1c_dir/1cv8c ENTERPRISE /S "${ACT_HOST}":"$ACT_REGPORT"/"$EMPTY_IB_NAME" \
  /Execute "${BASE_ACT_PATH}/${COMMUNITY_LICENSE_ACTIVATOR}" \
  /C "login=${DEV_LOGIN};password=${DEV_PASSWORD};agentHost=${ACT_HOST};agentPort=${ACT_REGPORT};acceptLicense=true" \
  /DisableStartupMessages \
  /UseHwLicenses- \
  </dev/null &

CLIENT_PID=$!
echo "[INFO] Waiting for license activator (PID=$CLIENT_PID)..."

wait "$CLIENT_PID" || echo "[WARN] License activator exited with non-zero code"

chown -R usr1cv8:grp1cv8 "$LICENSE_DIR"
chmod -R 755 "$LICENSE_DIR"

echo "[INFO] Shutting down server and Xvfb..."

echo "[INFO] License activator finished."