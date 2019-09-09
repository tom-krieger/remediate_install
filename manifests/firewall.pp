# @summary
#    Configure firewall if needed
#
# @param $kernel
#    The os kernel like Linux or Windows
#
# @api private
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
