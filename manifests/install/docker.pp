# @summary
#    Install docker and its prerequisites

class remediate_install::install::docker(
  $docker_users,
  $docker_ee,
) {

  class { 'docker':
    docker_ee      => $docker_ee,
    manage_package => true,
    manage_service => true,
    docker_users   => $docker_users,
  }

  if($facts['os']['name'] != 'CentOS') {

    $centos_packages = ['yum-utils','device-mapper-persistent-data','lvm2']

    package { $centos_packages:
      ensure => installed,
    }

  }
}
