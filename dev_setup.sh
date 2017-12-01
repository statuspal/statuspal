#!/usr/bin/env bash

set -e

rm -rf apps/statushq_pro
cp apps/statushq/config/dev.secret.template.exs apps/statushq/config/dev.secret.exs
mix deps.get
yarn
mix do ecto.create, ecto.migrate, run apps/statushq/priv/repo/seeds.exs
