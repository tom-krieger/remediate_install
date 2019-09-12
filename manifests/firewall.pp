# @summary
#    Configure firewall if needed
#
# @api private
class remediate_install::firewall (
) {

  class { "remediate_install::firewall::${facts['kernel'].downcase()}":
  }

}
