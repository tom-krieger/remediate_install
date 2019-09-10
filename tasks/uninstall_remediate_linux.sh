#!/bin/bash

cd $PT_install_dir

docker-compose run remediate stop

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
remote-edge.crt
remote-edge.key
root.crt
root.key
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

exit 0
