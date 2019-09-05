plan remediate_install::install (
  TargetSpec $nodes,
  String[1] $install_docker,
  String[1] $remove_old,
  String[1] $init_swarm,
  String $license_file     = undef,
  String $compose_version  = '1.24.1',
  String $win_install_dir  = 'c:\remediate',
  String $unix_install_dir = '/opt/remediate',
  Boolean $enforce_system_requirements = false
) {

  if(($install_docker != 'n') and ($install_docker != 'y')) {
    fail_plan("invalid value for install_docker parameter: ${install_docker}")
  }
  if(($remove_old != 'n') and ($remove_old != 'y')) {
    fail_plan("invalid value for remove_old parameter: ${remove_old}")
  }
  if(($init_swarm != 'y') and ($init_swarm != 'n')) {
    fail_plan("Invalid value for init_swarm parameter: ${init_swarm}")
  }

  if(file::exists($license_file) == false) {
    fail_plan("License file ${license_file} does not exist")
  } elsif (file::readable($license_file) == false) {
    fail_plan("License file ${license_file} is not eadable")
  }

  run_plan(facts, nodes => $nodes)
  $myfacts = get_targets($nodes)[0].facts

  # check system requirements

  # check hardware platform
  if($myfacts['os']['hardware'] != 'x86_64') {
    if($enforce_system_requirements) {
      fail_plan("Remediate is not supported on ${myfacts['os']['name']} hardware")
    } else {
      out::message("Remediate is not supported on ${myfacts['os']['name']} hardware")
    }

  }

  # check os version and
  case $myfacts['os']['name'] {
    'RedHat', 'CentOS':  {
      if($myfacts['os']['release']['major'] < '7') {
        if($enforce_system_requirements) {
          fail_plan("Remediate is not supported on Redhat/CentOS version ${myfacts['os']['releae']['major']}. It has to be at least 7.")
        } else {
          out::message("Remediate is not supported on Redhat/CentOS version ${myfacts['os']['releae']['major']}. It has to be at least 7.")
        }
      }
    }
    'Debian':            {
      if($myfacts['os']['release']['major'] < '8') {
        if($enforce_system_requirements) {
          fail_plan("Remediate is not supported on Debian version ${myfacts['os']['releae']['major']}. It has to be at least 8.")
        } else {
          out::message("Remediate is not supported on Debian version ${myfacts['os']['releae']['major']}. It has to be at least 8.")
        }
      }
    }
    'Ubuntu':            {
      if($myfacts['os']['release']['major'] < '14.04') {
        if($enforce_system_requirements) {
          fail_plan("Remediate is not supported on Ubuntu version ${myfacts['os']['releae']['major']}. It has to be at least 14.04.")
        } else {
          out::message("Remediate is not supported on Ubuntu version ${myfacts['os']['releae']['major']}. It has to be at least 14.04.")
        }
      }
    }
    'Windows':           {
      if($myfacts['os']['release']['major'] == '10') {
        if($enforce_system_requirements) {
          fail_plan("Remediate is not supported on Windowa version ${myfacts['os']['releae']['major']}. It has to be at least 10.")
        } else {
          out::message("Remediate is not supported on Windowa version ${myfacts['os']['releae']['major']}. It has to be at least 10.")
        }
      }
    }
    default:             {
      fail_plan("OS ${myfacts['os']['name']} is not supported.")
    }
  }

  # check system meory
  if($myfacts['memory']['system']['total_bytes'] < 8589934592) {
    if($enforce_system_requirements) {
    fail_plan('System memory has to be not lower than 8 GB.')
    } else {
      out::message('System memory has to be not lower than 8 GB.')
    }
  }

  # check cpu count
  if($myfacts['processors']['count'] < 2) {
    if($enforce_system_requirements) {
    fail_plan('Remediate need 2 cpus at minimum.')
    } else {
      out::message('Remediate need 2 cpus at minimum.')
    }
  }

  # run installation
  if($install_docker == 'y') {

    # install docker
    case $myfacts['os']['name'] {
      'Solaris':           {
        fail_plan('Solaris is currently not supported')
      }
      'RedHat', 'CentOS':  {
        $result = run_task('remediate_install::install_docker', $nodes, os => 'Redhat', ostype => 'Redhat', removeold => $remove_old)
      }
      'Debian':            {
          $result = run_task('remediate_install::install_docker', $nodes, os => 'Debian', ostype => 'Debian', removeold => $remove_old)
      }
      'Ubuntu':            {
        $result = run_task('remediate_install::install_docker', $nodes, os => 'Debian', ostype => 'Ubuntu', removeold => $remove_old)
      }
      'Suse':              {
        fail_plan('Suse SLES is currently not supported')
      }
      default:             {
        fail_plan('Unsupported OS')
      }
    }

  }

  if($init_swarm == 'y') {

    $result_swarm = run_task('remediate_install::swarm_init', $nodes)

  }

  # check for docker compose and install if not present
  run_task('remediate_install::install_docker_compose', $nodes, compose_version => $compose_version)

  # install remedeate
  case $myfacts['kernel'] {
    'Linux': {
      $install_dir = $unix_install_dir
    }
    'Windows': {
      $install_dir = $win_install_dir
    }
    default: {
      fail_plan("unknown system kernel ${myfacts['kernel']}")
    }
  }
  run_task('remediate_install::install_remediate', $nodes, license_file => $license_file, install_dir => $install_dir)

}
