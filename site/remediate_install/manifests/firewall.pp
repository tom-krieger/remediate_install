# @summary
#    Configure firewall if needed
#
class remediate_install::firewall(
  String $kernel,
) {

  if($kernel == 'Linux') {
    Firewall {
      before  => Class['remediate_install::fw_post'],
      require => Class['remediate_install::fw_pre'],
    }

    class { 'firewall': }

    firewallchain { 'OUTPUT:filter:IPv4':
      ensure => present,
      policy => accept,
      before => undef,
    }

    firewall { '100 Allow inbound ssh':
      chain  => 'INPUT',
      dport  => 22,
      proto  => tcp,
      action => accept,
    }

    firewall { '101 Allow inbound Remediate console access':
      dport  => 8443,
      proto  => tcp,
      action => accept,
    }
  }
}
