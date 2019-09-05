# @summary
#    Firewall post rules
class remediate_install::fw_post {

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
