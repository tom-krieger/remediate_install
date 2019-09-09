# @summary
#    Firewall definition for Linux
#
# @api private
class remediate_install::firewall::linux {

  Firewall {
      before  => Class['remediate_install::firewall::linux::post'],
      require => Class['remediate_install::firewall::linux::pre'],
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

    firewall { '101 Allow inbound web access to Remediate':
      chain  => 'INPUT',
      dport  => 8443,
      proto  => tcp,
      action => accept,
    }

    firewall { '101 Allow inbound Remediate console access':
      dport  => 8443,
      proto  => tcp,
      action => accept,
    }
}
