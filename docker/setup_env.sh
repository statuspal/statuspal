#!/usr/bin/env bash

set -e

echo "Generating .env file for ya!"

cp -n ./.env_template ./.env
sed -i -e "s|SECRET_KEY_BASE=<genearate a secure key>|SECRET_KEY_BASE=$(openssl rand -base64 48)|g" ./.env
sed -i -e "s|NODE_COOKIE=<genearate another secure key>|NODE_COOKIE=$(openssl rand -base64 48)|g" ./.env
rm ./.env-e

echo "Done :)"
