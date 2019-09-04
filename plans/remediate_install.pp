plan remediate_install::install(
  Enum $install_docker = ['n', 'y'],
  Enum $init_swarm = ['n', 'y'],
  String $license_file = undef,
) {

  case $facts['os']['name'] {
    'Solaris':           {
      fail_plan('Solaris is currently not supported')
    }
    'RedHat', 'CentOS':  {
      $result = run_task('remediate_install::install_docker_linux', os => 'Redhat', type => '')
    }
    'Debian':            {
        $result = run_task('remediate_install::install_docker_linux', os => 'Debian', type => 'Debian')
    }
    'Ubuntu':            {
      $result = run_task('remediate_install::install_docker_linux', os => 'Debian', type => 'Ubuntu')
    }
    'Suse':              {
      fail_plan('Suse SLES is currently not supported')
    }
    default:             {
      fail_plan('Unsupported OS')
    }
  }

  if($install_docker = 'y') {

    # install docker

  }

  if($init_swarm == 'y') {

    # initializse docker swarm

  }

  # check for docker compose

  # install docker compose


}
