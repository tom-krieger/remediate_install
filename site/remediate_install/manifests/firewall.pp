# @summary
#    Configure firewall if needed
#
class remediate_install::firewall(
  String $kernel,
) {

  case $kernel {
    'Linux': {
      class { 'remediate_install::firewall::linux':
      }
    }
    'Windows': {
      class { 'remediate_install::firewall::windows':
      }
    }
    default: {
      crit("No firewall definition for ${kernel}")
    }
  }
}
