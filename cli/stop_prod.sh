COMPOSE_DIR_PATH=../conf/production
docker-compose -f $COMPOSE_DIR_PATH/docker-compose.yml --project-directory=$COMPOSE_DIR_PATH/  -p delta down --rmi all