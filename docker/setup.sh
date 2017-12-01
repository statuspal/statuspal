#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

/statushq/docker/wait_for_postgres.sh postgres

mix ecto.create
mix ecto.migrate
mix run apps/statushq/priv/repo/seeds.exs
mix shq.default_user
