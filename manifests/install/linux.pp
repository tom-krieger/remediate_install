# @summary
#    Install remediate oin Linux
# 
# @param install_dir
#   Directory where to install Remediate
#
# @param license_file
#    Full qualified filename of the license file including path
#
# @param compose_dir 
#    Directory where to install docker-compose binary
#
# @param compose_url
#    URL of the Remediar docker compose file
#
# @api private
class remediate_install::install::linux (
  String $install_dir,
  String $license_file,
  String $compose_dir   = '',
  String $compose_url   = 'https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
) {
  if($compose_dir == '') {
    $cmd = 'docker-compose run remediate start --license-file license.json'
  } else {
    $cmd = "${compose_dir}/docker-compose run remediate start --license-file license.json"
  }

  file { $install_dir:
    ensure   => directory,
  }

  file { "${install_dir}/docker-compose.yml":
    ensure  => file,
    source  => $compose_url,
    require => File[$install_dir],
    notify  => Exec['install-remediate'],
  }

  file { "${install_dir}/license.json":
    ensure  => file,
    source  => "file://${license_file}",
    require => File[$install_dir],
    before  => Exec['install-remediate']
  }

  exec { 'install-remediate':
    command   => $cmd,
    path      => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    cwd       => $install_dir,
    logoutput => true,
    user      => 'root',
    before    => Class['remediate_install::install::linux::service'],
  }

  class { 'remediate_install::install::linux::service':
    install_dir => $install_dir,
    compose_dir => $compose_dir,
  }
}
