#!/bin/bash

set -e

host="$1"

until psql -U "postgres" -h "$host" -c '\q'  > /dev/null 2>&1; do
  >&2 echo "Waiting for Postgres..."
  sleep 1
done

>&2 echo "Postgres is up - executing command"
