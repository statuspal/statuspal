#!/usr/bin/env bash

set -e

NO_FORMAT="\033[0m"
C_FUCHSIA="\033[38;5;13m"

cd "$(dirname "$0")"
echo "DB_NAME: $DB_NAME, $REPLACE_OS_VARS"

./wait_for_postgres.sh

cd ..

STATIC_DIR="$(find /statushq/rel/statushq/lib -name 'statushq-*' -type d)/priv/static"
mkdir -p /statushq/rel/statushq/assets
cp -rf $STATIC_DIR/* /statushq/rel/statushq/assets/

# Up
psql -h "$DB_HOSTNAME" -U "$DB_USERNAME" -c "create database $DB_NAME;" || true
/statushq/rel/statushq/bin/statushq command Elixir.Statushq.ReleaseTasks ce_setup
printf "\n\n---> Starting Statuspal server at ${C_FUCHSIA}http://${URL_HOST}:${URL_PORT}${NO_FORMAT} <---\n"
printf "(Ignore the port mentioned below and or above)\n\n\n"
/statushq/rel/statushq/bin/statushq foreground
