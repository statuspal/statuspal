#!/usr/bin/env bash

set -ex

ACCOUNT=statuspal
IMAGE=statuspal

docker build -t $ACCOUNT/$IMAGE:latest . -f ./docker/Dockerfile
