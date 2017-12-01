#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

./wait_for_postgres.sh $1
cd ..
mix ecto.migrate
rel/statushq/bin/statushq foreground
