#!/bin/bash
set -e

if /1c_scripts/license_expiring_soon.sh; then
    echo "[INFO] Activating or renewing community license..."
    /1c_scripts/license_activator.sh
    echo "[INFO] License activation finished. Check logs at '/1c_dir/activation/' to debug."
fi

exec gosu usr1cv8 /1c_ragent \
  -debug \
  -d /var/1C/1cv8 \
  -port "${SERVER_PORT}" \
  -regport "${SERVER_AGENT_PORT}"
