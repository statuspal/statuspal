#!/bin/bash

set -e

until psql -h "$DB_HOSTNAME" -U "$DB_USERNAME" -c '\q'; do
  >&2 echo "Waiting for Postgres..."
  sleep 1
done

>&2 echo "Postgres is up - executing command"
