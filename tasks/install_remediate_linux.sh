#!/bin/bash

if [ ! -d "${PT_install_dir}" ] ; then
    sudo mkdir -p $PT_install_dir
    sudo chmod 755 $PT_install_dir
fi

cd $PT_install_dir

if [ ! -f docker-compose.yml ] ; then
    echo "downloadind remediate compose file"
    sudo curl -L https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml -o docker-compose.yml
fi

compose=$(sudo type docker-compose 2>/dev/null)
if [ -z "$compose" ] ; then
    compose="/usr/local/bin/docker-compose"
fi
sudo $compose run remediate start --license-file $PT_license_file

exit 0
