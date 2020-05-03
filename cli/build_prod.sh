COMPOSE_DIR_PATH=../conf/production
docker-compose --env-file $COMPOSE_DIR_PATH/.env -f $COMPOSE_DIR_PATH/docker-compose.yml -p delta build --no-cache
docker-compose --env-file $COMPOSE_DIR_PATH/.env -f $COMPOSE_DIR_PATH/docker-compose.yml  -p delta up -d --force-recreate