#!/bin/bash

if [ ! -d "/opt/remediate" ] ; then
    sudo mkdir -p /opt/remediate
    sudo chmod 755 /opt/remediate
fi

cd /opt/remediate

if [ ! -f docker-compose.yml ] ; then
    echo "downloadind remediate compose file"
    sudo curl -L https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml -o docker-compose.yml
fi

compose=$(sudo type docker-compose 2>/dev/null)
if [ -z "$compose" ] ; then
    compose="/usr/local/bin/docker-compose"
fi
sudo $compose run remediate start --license-file $PT_license

exit 0
