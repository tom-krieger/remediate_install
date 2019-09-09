# @summary
#    Firewall post rules
#
# Rules to be added at the end of the firewall
#
# @api private
class remediate_install::firewall::linux::post {

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
