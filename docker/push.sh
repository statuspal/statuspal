#!/usr/bin/env bash

set -ex

ACCOUNT=statuspal
IMAGE=statuspal

mix compile
mix test
VERSION=`mix version`

docker tag $ACCOUNT/$IMAGE:latest $ACCOUNT/$IMAGE:$VERSION
docker tag $ACCOUNT/$IMAGE:latest $ACCOUNT/$IMAGE:${VERSION%.*}

# push it
docker push $ACCOUNT/$IMAGE:latest
docker push $ACCOUNT/$IMAGE:$VERSION
docker push $ACCOUNT/$IMAGE:${VERSION%.*}
