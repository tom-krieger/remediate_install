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
  Enum['y', 'n'] $install_docker       = 'y',
  Enum['y', 'n'] $init_swarm           = 'y',
  Enum['y', 'n'] $install_compose      = 'y',
  Enum['y', 'n'] $install_remediate    = 'y',
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

    $requirements_ok = run_plan('remediate_install::check_requirements', 'nodes' => $target)
    notice($requirements_ok)
    if ! $requirements_ok {
      if $enforce_system_requirements {
        fail_plan("${target} does not meet Remediate requirements. Stopping installation.")
      }
      else {
        out::message("${target} does not meet Remediate requirements. Continuing installation (not enforcing system requirements).")
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
          class { 'remediate_install::install::docker':
            docker_users => $docker_users,
            docker_ee    => $docker_ee,
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
      out::message('installing docker compose')
      without_default_logging() || {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
          $default_compose_params = {
            'ensure'  => present,
            'version' => $compose_version,
          }
          if($facts['kernel'].downcase() == 'linux') {
            $compose_params = $default_compose_params + { 'install_path' => $compose_install_path }
          } else {
            $compose_params = $default_compose_params
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
      case $myfacts['kernel'].downcase() {
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

      out::message("uploading license file ${license_file}")

      $remote_license_file_path = '/tmp/license.json'
      upload_file($license_file, $remote_license_file_path, $target, "Uploading license file ${license_file}")

      out::message("installing Puppet Remediate in ${install_dir}")

      without_default_logging() || {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
          class { 'remediate_install::install':
            install_dir  => $install_dir,
            license_file => $remote_license_file_path,
            compose_dir  => $compose_path,
          }
        }
      }
    }
  }

  return('installation finished')
}
