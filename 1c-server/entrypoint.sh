#!/bin/bash
set -e

/1c_ragent \
  -debug \
  -d /var/1C/1cv8 \
  -port "${SERVER_PORT}" \
  -regport "${SERVER_AGENT_PORT}"
