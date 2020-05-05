#!/usr/bin/env bash

COMPOSE_ENV_PATH=../conf/docker-compose/envs/.env_prod
COMPOSE_PATH=../conf/docker-compose/app.prod.yml
docker-compose --env-file $COMPOSE_ENV_PATH -f $COMPOSE_PATH -p delta build --no-cache
docker-compose --env-file $COMPOSE_ENV_PATH -f $COMPOSE_PATH -p delta up -d --force-recreate