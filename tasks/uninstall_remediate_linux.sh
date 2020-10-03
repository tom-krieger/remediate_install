#!/bin/bash

echo "Install dir = $PT_install_dir"

cd $PT_install_dir

if [ -x /usr/local/bin/docker-compose ] ; then
    COMPOSE="/usr/local/bin/docker-compose"
elif [ -x /usr/bin/docker-compose ] ; then
    COMPOSE="/usr/bin/docker-compose"
else
    echo "no working docker-compose command found!"
    exit 1
fi

$COMPOSE run remediate stop

docker service ls | grep remediate_ | awk '{print $1;}' | while read srv ; do 

    docker service rm $srv
    
done

docker ps -a | grep 'remediate_' | awk '{print $1" "$2;}' | while read id img ; do

    docker stop $id
    sleep 2
    docker rm $id
    docker image rm $img

done

docker image ls | grep -e "gcr.io/puppet-discovery" -e "vault" | awk '{print $3;}' | while read img ; do

    docker image rm "${img}"

done

SECRETS="admin_password
admin_user
audit.crt
audit.key
controller.crt
controller.key
edge.crt
edge.key
encryption_key.txt
export.crt
export.key
frontdoor.crt
frontdoor.key
gopdp.crt
gopdp.key
identity.crt
identity.key
identity_realm.json
licensing.crt
licensing.key
oauth_client.json
root.crt
storage.crt
storage.key
ui.crt
ui.key
vault.crt
vault.key
vr.crt
vr.key"

for scrt in $SECRETS ; do

    docker secret rm $scrt

done

docker volume ls | grep "remediate_" | awk '{print $2;}' | while read vol ; do

    docker volume rm $vol

done

docker ps -a
docker image ls
docker volume ls
docker secret ls

exit 0
