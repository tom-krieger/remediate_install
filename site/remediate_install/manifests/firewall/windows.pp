# @summary
#    Firewall definition for windows
#
class remediate_install::firewall::windows {

  class { 'windows_firewall': ensure => 'running' }

  windows_firewall::exception { 'REMWEB':
    ensure       => present,
    direction    => 'in',
    action       => 'allow',
    enabled      => true,
    protocol     => 'TCP',
    local_port   => 8443,
    remote_port  => 'any',
    display_name => 'Remediate web console access',
    description  => 'Inbound rule for acess to Remediate console (Port 8443)',
  }

  windows_firewall::exception { 'WINRM-fallback':
    ensure       => present,
    direction    => 'both',
    action       => 'allow',
    enabled      => true,
    protocol     => 'TCP',
    local_port   => 5985,
    remote_port  => 'any',
    display_name => 'Windows Remote Management HTTP-In',
    description  => 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]',
  }

  windows_firewall::exception { 'WINRM':
    ensure       => present,
    direction    => 'both',
    action       => 'allow',
    enabled      => true,
    protocol     => 'TCP',
    local_port   => 5986,
    remote_port  => 'any',
    display_name => 'Windows Remote Management HTTP-In',
    description  => 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]',
  }

  windows_firewall::exception { 'REM-SSH-OUT':
    ensure       => present,
    direction    => 'out',
    action       => 'allow',
    enabled      => true,
    protocol     => 'TCP',
    local_port   => 'any',
    remote_port  => 22,
    display_name => 'Remediate SSH outbound access',
    description  => 'Outbound rule for ssh access.',
  }

  windows_firewall::exception { 'REM-HTPS-OUT':
    ensure       => present,
    direction    => 'out',
    action       => 'allow',
    enabled      => true,
    protocol     => 'TCP',
    local_port   => 'any',
    remote_port  => 443,
    display_name => 'Remediate HTTPS outbound access',
    description  => 'Outbound rule for HTTPS access.',
  }
}
