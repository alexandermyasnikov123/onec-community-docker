#!/bin/bash

#mkdir -p data/{licenses,server_data,server_logs,client_home,pg_data}
#docker compose up -d --build

export "$(cat .env | grep BASE_MOUNT_DIR)"
mkdir -p "${BASE_MOUNT_DIR}"/data/{1c-postgres_data,1c-server_opt,1c-server_licenses,1c-server_data,1c-client_home}
chmod -R 777 data
docker compose up --build
