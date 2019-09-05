#!/bin/bash

if [ "$(sudo docker info | grep Swarm | awk '{print $2;}')" == "inactive" ]; then
    echo "initializing docker aswarm"
    sudo docker swarm init
else
    echo "docker swarm already initialized"
fi

exit 0
