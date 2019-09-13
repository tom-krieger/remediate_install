# @summary
#    Install docker and its prerequisites
#
# Install docker software and configure docker
#
# @param docker_users
#    Users to add to the docker group
#
# @param docker_ee
#    Install docker enterprise edition. Set to true for ee
#
# @api private 
class remediate_install::install::docker (
  Array $docker_users,
  Boolean $docker_ee,
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
