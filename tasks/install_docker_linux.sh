#!/bin/bash

os=$PT_os
type=$PT_ostype
removeold=$PT_removeold

echo "docker installation for os = $os and type = $type"

if [ "$os" = "Redhat" ] ; then
    # remove old docker installations
    oldpkgs="docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine"

    newpkgs="yum-utils device-mapper-persistent-data lvm2 containerd.io docker-ce docker-ce-cli"

    if [ "$removeold" = "y" ] ; then
        for pkg in $oldpkgs ; do
        
            rpm -q $pkg > /dev/null
            if [ $? = 0 ] ; then
                sudo yum remove -y $pkg
            fi

        done
    fi

    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    for pkg in $newpkgs ; do
        yum -y install $pkg
    done

    sudo systemctl enable docker
    sudo systemctl start docker

elif [ "$os" = "Debian" -o "$os" = "Ubuntu" ] ; then

    # remove old docker installations
    olgpkgs="docker docker-engine docker.io containerd runc"

    newpkgs="apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common \
         docker-ce \
         docker-ce-cli \
         containerd.io"

    if [ "$removeold" = "y" ] ; then
        for pkg in $oldpkgs ; do
            apt-get remove -y $pkg
        done
    fi

    apt-get update

    curl -fsSL https://download.docker.com/linux/${type}/gpg | apt-key add -

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${type} $(lsb_release -cs) stable"

    sudo apt-get update

    for pkg in $newpkgs ; do
        apt-get install -y $pks
    done

    systemctl enable docker
    systemctl start docker

else
    echo "Unknown OS $os"
    exit 1
fi

exit 0