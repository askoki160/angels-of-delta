#!/usr/bin/env bash

set -e

source ./conf/Server/env/dev_env.sh
#source ./conf/Server/env/prod_env.sh

TARGET_DIR=conf/dev-certs

ROOT_DNS=$WEB_PUBLIC_HOST

KEY_TARGET=privkey.pem
CRT_TARGET=fullchain.pem

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p $TARGET_DIR
fi


# build certs if they don't exist
if [ ! -f "$TARGET_DIR/$KEY_TARGET" ] || [ ! -f "$TARGET_DIR/$CRT_TARGET" ]; then
    echo -e "creates a self signed ssl certificate for:\n\n$ROOT_DNS"
    openssl req -x509 -out $TARGET_DIR/$CRT_TARGET -keyout $TARGET_DIR/$KEY_TARGET  \
        -newkey rsa:2048 -nodes -sha256  \
        -subj "/CN=$ROOT_DNS" \
        -days 3650 -extensions EXT -config <( \
        printf "[dn]\nCN=$ROOT_DNS\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$ROOT_DNS\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

fi
