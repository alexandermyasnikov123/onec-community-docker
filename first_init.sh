#!/bin/bash

mkdir -p data/{licenses,server_data,server_logs,client_home,pg_data}
chmod -R 777 data
docker compose up -d
