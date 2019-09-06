# @summary Install Puppet Remediate
#
# Bolt plan to install Puppet remediate. 
#
# @param $nodes
#    The target nodes
#
# @param $install_docker
#    Flag fpr Docker install. Valid input: 'y' or 'no'
#
# @param $init_swarm
#    Initialize Docker Swarm during installation. This will initialize a first manager swarm node. 
#    Valid input: 'y' or 'n'
#
# @param $install_compose
#    Install docker-compose binary which is needed for Remediate installation. Valid input: 'y' or 'n'.
#
# @param $compose_version
#    The version of docker-compose to install if installation of docker-compose is requested. 
#    Please keep in mind that Remedieate needs version 1.24.1 of docker-compose at least.
#
# @param $install_remediate
#    Install Remediate. Valid input: 'y' or 'n'
#
# @param $configure_firewall
#    Serup a firewall with all rules needed for Remediate. If unsure please set this parameter to no 
#    and do the firewall configuration yourself. Valid input: 'y' or 'n'
#
# @param $license_file
#    Full qualified filename of teh Remediate license file. 
#
# @param $compose_version
#    The version of docker-compose to install if installation of docker-compose is requested. 
#    Please keep in mind that Remedieate needs version 1.24.1 of docker-compose at least.
#
# @param $compose_install_path
#    Path where to install docker-compose binary 
#
# @param $win_install_dir
#    Directory where to install Remediate on Windo´ws systems
#
# @param $unix_install_dir
#    Directory where to install Remediate on Unix systems
#
# @param $enforce_system_requirements
#    Set to true the installer breaks if the system requirements for Remediate are not met.
#
# @param $noop_mode
#    Run apply commands in noop mode. If set to true no changes will be made to the system
#
# @example 
#    bolt plan run remediate_install::check_requirements -n localhost
#
# @example
#    bolt plan run remediate_install install_docker=y init_swarm=y license_file=/opt/remediate/vr-license.json \
#    remove_old=y install_compose=y install_remediate=y configure_firewall=y -n localhost --run-as root 
plan remediate_install (
  TargetSpec $nodes,
  String[1] $install_docker,
  String[1] $init_swarm,
  String[1] $install_compose,
  String[1] $install_remediate,
  String[1] $configure_firewall = 'n',
  String $license_file     = undef,
  String $compose_version  = '1.24.1',
  String $compose_install_path = '/usr/local/bin',
  String $win_install_dir  = 'c:\remediate',
  String $unix_install_dir = '/opt/remediate',
  Boolean $enforce_system_requirements = false,
  Boolean $noop_mode = false,
) {

  if(($install_docker != 'n') and ($install_docker != 'y')) {
    fail_plan("invalid value for install_docker parameter: ${install_docker}")
  }
  if(($init_swarm != 'y') and ($init_swarm != 'n')) {
    fail_plan("Invalid value for init_swarm parameter: ${init_swarm}")
  }
  if(($install_compose != 'n') and ($install_compose != 'y')) {
    fail_plan("Invalid value for install_compose: ${install_compose}")
  }
  if(($install_remediate != 'n') and ($install_remediate != 'y')) {
    fail_plan("Invalid value for install_compose: ${install_remediate}")
  }
  if(($configure_firewall != 'n') and ($configure_firewall != 'y')) {
    fail_plan("Invalid value for install_compose: ${configure_firewall}")
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
      crit("Remediate is not supported on ${myfacts['os']['name']} hardware")
    }

  }

  # check os version and
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
      if($myfacts['os']['release']['major'] == '10') {
        if($enforce_system_requirements) {
          fail_plan("Remediate is not supported on Windowa version ${myfacts['os']['releae']['major']}. It has to be at least 10.")
        } else {
          crit("Remediate is not supported on Windowa version ${myfacts['os']['releae']['major']}. It has to be at least 10.")
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
      crit('System memory has to be not lower than 8 GB.')
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

  # run installation
  if($install_docker == 'y') {

    # install docker and additional rpm packages
    out::message('installing docker')
    apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
      class { 'docker':
        docker_ee      => false,
        manage_package => true,
        manage_service => true,
      }

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

  if($init_swarm == 'y') {
    out::message('install docker swarm')
    apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
      docker::swarm {'swarm':
        init => true,
      }
    }

  }

  # check for docker compose and install if not present
  if($install_compose == 'y') {
    out::message('install docker compose')
    apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
      class {'docker::compose':
        ensure       => present,
        version      => $compose_version,
        install_path => $compose_install_path,
      }
    }
    $compose_path = $compose_install_path
  } else {
    $compose_path = ''
  }

  # configure firewall
  if($configure_firewall == 'y') {
    out::message('configuring firewall')
    $res = run_task('remediate_install::check_firewall', $nodes)
    $fwd = $res.first
    if(($fwd['iptables'] == 'enabled') or ($fwd['firewalld'] == 'enabled')) {
        apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
        class { 'remediate_install::firewall':
          kernel => $myfacts['kernel'],
        }
      }
    } else {
      warning('No firewall running on host, no configuration will be done')
    }

  }

  # install remedeate
  if($install_remediate == 'y') {
    out::message('install remediate')
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

    out::message("installing Remediate in ${install_dir}")

    apply($nodes, _catch_errors => true, _noop => $noop_mode, _run_as => root) {
      class { 'remediate_install::install':
        install_dir  => $install_dir,
        license_file => $license_file,
        compose_dir  => $compose_path
      }
    }
  }
}
