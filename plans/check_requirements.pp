# @summary
#    Check Remediate installation prerequiasites
#
# @param $nodes
#    Nodes to run on
#
# @example Requirements check on Windows host
#    bolt plan run remediate_install::check_requirements -n <host> --user Administrator \
#              --password <password> --transport winrm --no-ssl
#
# @example Requiremets check on Ubuntu host
#    bolt plan run remediate_install::check_requirements -n <host> --run-as root --user ubuntu \ 
#              --private_key <private key file> --no-host-key-check
plan remediate_install::check_requirements (
  TargetSpec $nodes,
) {
  get_targets($nodes).each |$target| {

    $target.apply_prep()
    $myfacts = facts($target)

    out::message('System requirements check started ...')

    # check system requirements
    # check hardware platform
    if($myfacts['os']['hardware'] != 'x86_64') {
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
          crit("Remediate is not supported on Windows version ${myfacts['os']['release']['major']}. It is only supported on Windows 10.")
        }
      }
      default:             {
        crit("OS ${myfacts['os']['name']} is not supported.")
      }
    }

    # check system meory
    if($myfacts['memory']['system']['total_bytes'] < 8589934592) {
      crit('System memory has to be at least 8 GB.')
    }

    # check cpu count
    if($myfacts['processors']['count'] < 2) {
      crit('Remediate need 2 cpus at minimum.')
    }

    out::message('System requirements check finished')
  }
}
