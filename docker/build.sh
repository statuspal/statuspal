#!/usr/bin/env bash

set -e

docker-compose -f docker/docker-compose.yml build $@
