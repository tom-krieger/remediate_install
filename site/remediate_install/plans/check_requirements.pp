# @summary
#    Check Remediate installation prerequiasites
#
# @param $nodes
#    Nodes to run on
#
plan remediate_install::check_requirements (
  TargetSpec $nodes,
) {
  run_plan(facts, nodes => $nodes)
  $myfacts = get_targets($nodes)[0].facts

  # check system requirements
  # check hardware platform
  if($myfacts['hardwaremodel'] != 'x86_64') {
    crit("Remediate is not supported on ${myfacts['os']['name']} hardware")
  }

  # check os version and
  case $myfacts['os']['name'] {
    'RedHat', 'CentOS':  {
      if($myfacts['os']['release']['major'] < '7') {
        crit("Remediate is not supported on Redhat/CentOS version ${myfacts['os']['releae']['major']}. It has to be at least 7.")
      }
    }
    'Debian':            {
      if($myfacts['os']['release']['major'] < '8') {
        crit("Remediate is not supported on Debian version ${myfacts['os']['releae']['major']}. It has to be at least 8.")
      }
    }
    'Ubuntu':            {
      if($myfacts['os']['release']['major'] < '14.04') {
        crit("Remediate is not supported on Ubuntu version ${myfacts['os']['releae']['major']}. It has to be at least 14.04.")
      }
    }
    'Windows':           {
      if($myfacts['os']['release']['major'] != '10') {
        crit("Remediate is not supported on Windowa version ${myfacts['os']['releae']['major']}. It has to be at least 10.")
      }
    }
    default:             {
      crit("OS ${myfacts['os']['name']} is not supported.")
    }
  }

  # check system meory
  if($myfacts['memorysize_mb'] < '8192') {
    crit('System memory has to be not lower than 8 GB.')
  }

  # check cpu count
  if($myfacts['processors']['count'] < 2) {
    crit('Remediate need 2 cpus at minimum.')
  }
}
