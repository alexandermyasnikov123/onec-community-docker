#!/bin/bash
set -euo pipefail

export BASE_ACT_PATH=/1c_dir/activation
mkdir -p "${BASE_ACT_PATH}"

CURRENT_SERVICE_UP_TIME=$(date +%Y_%m_%d_%H_%M_%S)
export CURRENT_SERVICE_UP_TIME

export LOG_FILE="${BASE_ACT_PATH}/log_${CURRENT_SERVICE_UP_TIME}.log"

touch "${LOG_FILE}"
exec > >(tee -a "$LOG_FILE") 2>&1

if /1c_scripts/license_expiring_soon.sh >/dev/null 2>&1; then
    echo "[INFO] Need to [re]activate on the server side... Please, wait until finished."
    /1c_scripts/license_activator.sh
fi

echo "[INFO] The ragent is started."
gosu usr1cv8 /1c_ragent \
  -debug \
  -d /var/1C/1cv8 \
  -port 1540 \
  -regport 1541 &

until ss -ltn | grep -q ":1540"; do
  sleep 1
done

echo "[INFO] Starting ras..."
gosu usr1cv8 /1c_ras cluster \
  --port 1545 \
  localhost:1540 &

wait
