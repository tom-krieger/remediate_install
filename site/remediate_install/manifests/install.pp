# @summary
#    Install Puppet remedeiate docker containers
#
class remediate_install::install (
  String $install_dir,
  String $license_file,
  String $compose_url = ' https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
) {

  file { $install_dir:
    ensure => directory,
  }

  file { "${install_dir}/docker-compose.yml":
    ensure  => file,
    source  => $compose_url,
    require => File[$install_dir],
  }

  exec { 'install-remediate':
    refreshonly => true,
    command     => "docker-compose run remediate start --license-file ${license_file}",
  }
}
