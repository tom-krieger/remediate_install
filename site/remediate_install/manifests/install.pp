# @summary
#    Install Puppet remedeiate docker containers
#
class remediate_install::install (
  String $install_dir,
  String $license_file,
  String $compose_dir = '',
  String $compose_url = 'https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
) {

  if($compose_dir == '') {
    $cmd = 'docker-compose run remediate start --license-file license.json'
  } else {
    $cmd = "${compose_dir}/docker-compose run remediate start --license-file license.json"
  }

  file { $install_dir:
    ensure => directory,
  }

  file { "${install_dir}/docker-compose.yml":
    ensure  => file,
    source  => $compose_url,
    require => File[$install_dir],
    notify  => Exec['install-remediate'],
  }

  file { "${install_dir}/license.json":
    ensure => file,
    source => "file://${license_file}",
  }

  exec { 'install-remediate':
    refreshonly => true,
    command     => $cmd,
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    cwd         => $install_dir,
    logoutput   => true,
    user        => 'root',
  }
}
