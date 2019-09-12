# @summary Install Puppet Remediate
#
# Bolt plan to install Puppet Remediate. 
#
# @param nodes
#    The target nodes
#
# @param install_docker
#    Flag fpr Docker install.  
#    Valid input: 'y' or 'no'
#
# @param init_swarm
#    Initialize Docker Swarm during installation. This will initialize a first manager swarm node.  
#    Valid input: 'y' or 'n'
#
# @param install_compose
#    Install docker-compose binary which is needed for Remediate installation.  
#    Valid input: 'y' or 'n'.
#
# @param compose_version
#    The version of docker-compose to install if installation of docker-compose is requested. 
#    Please keep in mind that Remedieate needs version 1.24.1 of docker-compose at least.
#
# @param install_remediate
#    Install Remediate.  
#    Valid input: 'y' or 'n'
#
# @param configure_firewall
#    Serup a firewall with all rules needed for Remediate. If unsure please set this parameter to no 
#    and do the firewall configuration yourself. If you manage the firewall on the box with Puppet or some
#    other tool please set this parameter to 'n'.  
#    Valid input: 'y' or 'n'
#
# @param license_file
#    Full qualified filename of the Remediate license file. 
#
# @param docker_users
#    Users to add to the docker group
#
# @param compose_version
#    The version of docker-compose to install if installation of docker-compose is requested. 
#    Please keep in mind that Remedieate needs version 1.24.1 of docker-compose at least.
#
# @param compose_install_path
#    Path where to install docker-compose binary 
#
# @param win_install_dir
#    Directory where to install Remediate on Windows boxes
#
# @param unix_install_dir
#    Directory where to install Remediate on Unix systems
#
# @param enforce_system_requirements
#    Set to true the installer breaks if the system requirements for Remediate are not met.
#
# @param noop_mode
#    Run apply commands in noop mode. If set to true no changes will be made to the system
#
# @param docker_ee
#    Flag to install Docker Enterprise. Must be set to true on Windows boxes.
#
# @example Upload license file
#    bolt file upload /tmp/license.json /tmp/vr-license.json -n <host> --user <user> \
#              [--private_key <path to privare-key>] [--password] --no-host-key-check
# @example Requirements check
#    bolt plan run remediate_install::check_requirements -n <host> --run-as root --user <user> \
#              [--private_key <path to privare-key>] [--password] --no-host-key-check
#
# @example Remediate installation
#    bolt plan run remediate_install install_docker=y init_swarm=y license_file=/tmp/license.json \
#          install_compose=y install_remediate=y configure_firewall=y -n <host> --run-as root \
#          --user <user> [--private_key <path to privare-key>] [--password] --no-host-key-check \
#          [--sudo-password [PASSWORD]]
# 
plan remediate_install (
  TargetSpec $nodes,
  Enum['y', 'n'] $install_docker,
  Enum['y', 'n'] $init_swarm,
  Enum['y', 'n'] $install_compose,
  Enum['y', 'n'] $install_remediate,
  Enum['y', 'n'] $configure_firewall   = 'n',
  String $license_file                 = undef,
  Array $docker_users                  = ['centos'],
  String $compose_version              = '1.24.1',
  String $compose_install_path         = '/usr/local/bin',
  String $win_install_dir              = 'C:/Users/Administrator/remediate',
  String $unix_install_dir             = '/opt/remediate',
  Boolean $enforce_system_requirements = true,
  Boolean $noop_mode                   = false,
  Boolean $docker_ee                   = false,
) {
  get_targets($nodes).each |$target| {

    $target.apply_prep()
    $myfacts = facts($target)

    # check system requirements
    # check hardware platform
    if($myfacts['os']['hardware'] != 'x86_64') {
      if($enforce_system_requirements) {
        fail_plan("Remediate is not supported on ${myfacts['hardwaremodel']} hardware")
      } else {
        crit("Remediate is not supported on ${myfacts['hardwaremodel']} hardware")
      }
    }

    # check os version
    case $myfacts['os']['name'] {
      'RedHat', 'CentOS':  {
        if($myfacts['os']['release']['major'] < '7') {
          if($enforce_system_requirements) {
            fail_plan("Remediate is not supported on Redhat/CentOS version ${myfacts['os']['releae']['major']}. It has to be at least 7.")
          } else {
            crit("Remediate is not supported on Redhat/CentOS version ${myfacts['os']['releae']['major']}. It has to be at least 7.")
          }
        }
      }
      'Debian':            {
        if($myfacts['os']['release']['major'] < '8') {
          if($enforce_system_requirements) {
            fail_plan("Remediate is not supported on Debian version ${myfacts['os']['releae']['major']}. It has to be at least 8.")
          } else {
            crit("Remediate is not supported on Debian version ${myfacts['os']['releae']['major']}. It has to be at least 8.")
          }
        }
      }
      'Ubuntu':            {
        if($myfacts['os']['release']['major'] < '14.04') {
          if($enforce_system_requirements) {
            fail_plan("Remediate is not supported on Ubuntu version ${myfacts['os']['releae']['major']}. It has to be at least 14.04.")
          } else {
            crit("Remediate is not supported on Ubuntu version ${myfacts['os']['releae']['major']}. It has to be at least 14.04.")
          }
        }
      }
      'Windows':           {
        if($myfacts['os']['release']['major'] != '10') {
          $msg = "Remediate is not supported on Windows version ${myfacts['os']['release']['major']}. It is only supported on Windows 10."
          if($enforce_system_requirements) {
            fail_plan($msg)
          } else {
            crit($msg)
          }
        }
      }
      default:             {
        fail_plan("OS ${myfacts['os']['name']} is not supported.")
      }
    }

    # check system memory
    if($myfacts['memory']['system']['total_bytes'] < 8589934592) {
      if($enforce_system_requirements) {
        fail_plan('System memory has to be at least 8 GB.')
      } else {
        crit('System memory has to be at least 8 GB.')
      }
    }

    # check cpu count
    if($myfacts['processors']['count'] < 2) {
      if($enforce_system_requirements) {
        fail_plan('Remediate need 2 cpus at minimum.')
      } else {
        crit('Remediate need 2 cpus at minimum.')
      }
    }

    out::message(' ')
    out::message('====================================================================')
    out::message(' ')
    out::message("Install docker .............. : ${install_docker}")
    out::message("     -> docker ee ........... : ${docker_ee}")
    out::message("Initialize docker swarm ..... : ${init_swarm}")
    out::message("Install docker-comose ....... : ${install_compose}")
    if($install_compose == 'y') {
      out::message("Compose install directory ... : ${compose_install_path}")
      out::message("Docker compose version ...... : ${compose_version}")
    }
    out::message("Install Remediate ........... : ${install_remediate}")
    if($install_remediate == 'y') {
      if($myfacts['kernel'] == 'Linux') {
        out::message("Remediate install directory . : ${unix_install_dir}")
      } elsif($myfacts['k4rnel'] == 'windows') {
        out::message("Remediate install directory . : ${win_install_dir}")
      }
    }
    out::message("Configure firewall .......... : ${configure_firewall}")
    out::message("Noop mode ................... : ${noop_mode}")
    out::message("Enforce system requirements . : ${enforce_system_requirements}")
    out::message(' ')
    out::message('====================================================================')
    out::message(' ')

    # run Remediate installation steps
    if($install_docker == 'y') {
      # install docker and additional rpm packages
      out::message('installing docker')
      without_default_logging() || {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {

          class { 'docker':
            docker_ee      => $docker_ee,
            manage_package => true,
            manage_service => true,
            docker_users   => $docker_users,
          }

          if($facts['os']['name'] != 'CentOS') {
            package { 'yum-utils':
              ensure => installed,
            }

            package { 'device-mapper-persistent-data':
              ensure => installed,
            }

            package {'lvm2':
              ensure => installed
            }
          }
        }
      }
    }

    if($init_swarm == 'y') {
      out::message('initializing docker swarm')
      without_default_logging() || {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
          docker::swarm {'swarm':
            init => true,
          }
        }
      }
    }

    # check for docker compose and install if not present
    if($install_compose == 'y') {
      out::message('install docker compose')
      without_default_logging() || {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
          if($facts['kernel'].downcase() == 'windows') {
            $compose_params = {
              'ensure'  => present,
              'version' => $compose_version,
            }
          } else {
            $compose_params = {
              ensure       => present,
              version      => $compose_version,
              install_path => $compose_install_path,
            }
          }

          class {'docker::compose':
            *  => $compose_params,
          }
        }
      }
      $compose_path = $compose_install_path
    } else {
      $compose_path = ''
    }

    # configure firewall
    if($configure_firewall == 'y') {
      without_default_logging() || {
        $res = run_task('remediate_install::check_firewall', $nodes)
        $fwd = $res.first
        if($fwd['firewall'] == 'disabled') {
          out::message('configuring firewall')
          apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
            class { 'remediate_install::firewall':
            }
          }
        } else {
          warning('Firewall already running on host, no configuration will be done')
        }
      }
    }

    # install remedeate
    if($install_remediate == 'y') {
      case facts['kernel'].downcase() {
        'linux': {
          $install_dir = $unix_install_dir
        }
        'windows': {
          $install_dir = $win_install_dir
        }
        default: {
          fail_plan("unknown system kernel ${myfacts['kernel']}")
        }
      }

      out::message("installing Puppet Remediate in ${install_dir}")

      without_default_logging() || {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
          class { 'remediate_install::install':
            install_dir  => $install_dir,
            license_file => $license_file,
            compose_dir  => $compose_path,
          }
        }
      }
    }
  }

  return('installation finished')
}
