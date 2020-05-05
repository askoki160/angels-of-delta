#!/usr/bin/env bash

COMPOSE_ENV_PATH=../conf/docker-compose/envs/.env_dev
COMPOSE_PATH=../conf/docker-compose/app.dev.yml
docker-compose --env-file $COMPOSE_ENV_PATH -f $COMPOSE_PATH  -p delta down --rmi all