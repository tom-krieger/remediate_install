#!/bin/bash

version=$PT_compose_version

type docker-compose >/dev/null 2>&1
if [ $? != 0 ] ; then
    echo "downloading docker-compose"
    sudo curl -L "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" \
              -o /usr/local/bin/docker-compose
    sudo chmod 755 /usr/local/bin/docker-compose
fi

exit 0
