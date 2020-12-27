#!/bin/bash

# load config environment from file
if [ -f .env ]; then
    source .env
fi
docker run -it $DOCKER_REPOSITORY:slim