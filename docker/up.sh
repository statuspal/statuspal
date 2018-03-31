#!/usr/bin/env bash

set -e

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
/statushq/rel/statushq/bin/statushq foreground
