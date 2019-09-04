#!/bin/bash

os=$PT_os
type=$PT_type

if [ "$os" == 'Redhat'] ; then
    # remove old docker installations
    yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine

    yum install -y yum-utils device-mapper-persistent-data lvm2

    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    yum install -y docker-ce docker-ce-cli containerd.io

    systemctl enable docker
    systemctl start docker

elif [ "$os" == 'Debian' -o "$os" == "Ubuntu" ] ; then

    # remove old docker installations
    apt-get remove docker docker-engine docker.io containerd runc

    apt-get update
    apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/${type}/gpg | apt-key add -

    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${type} $(lsb_release -cs) stable"

    apt-get update

    apt-get install -y docker-ce docker-ce-cli containerd.io

    systemctl enable docker
    systemctl start docker

else
    echo "Unknown OS $os"
    exit 1
fi

exit 0