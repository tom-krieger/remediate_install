#!/bin/bash

if [ "$(sudo docker info | grep Swarm | sed 's/Swarm: //g')" == "inactive" ]; then
    sudo docker swarm init
fi

exit 0
