#!/bin/bash

# load config environment from file
if [ -f .env ]; then
    source .env
fi

docker push $DOCKER_REPOSITORY:slim
docker push $DOCKER_REPOSITORY:$CENTOS_VERSION-slim