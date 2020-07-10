#!/bin/bash

# Valid options are start | stop | restart
COMMAND=$1

# This File Builds and Starts a new Docker Environment
cd ../docker/

case "$COMMAND" in

    'start')
        docker build -t r10kbitbuckethook .
        docker-compose up -d
        ;;
    'restart')
        docker-compose restart
        ;;
    'stop')
        docker-compose down
        ;;
    'build')
        docker build -t r10kbitbuckethook .
        ;;
esac

cd ../scripts

echo "Container is now running, please attach to valid Webserver if running production"