# @summary
#    Install remediate on windows
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
class remediate_install::install::windows (
  String $install_dir,
  String $license_file,
  String $compose_dir   = '',
  String $compose_url   = 'https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
){

  $cmd = 'docker-compose run remediate start --license-file license.json'

  file { $install_dir:
    ensure   => directory,
  }

  file { $license_file:
    ensure  => file,
    noop    => true,
    require => File[$install_dir],
  }

  archive { "${install_dir}/docker-compose.yml":
    ensure         => present,
    source         => $compose_url,
    require        => File[$install_dir],
    notify         => Exec['install-remediate'],
    allow_insecure => true,
  }

  file { "${install_dir}/license.json":
    ensure  => file,
    source  => "file:///${license_file}",
    require => File[$license_file],
    before  => Exec['install-remediate']
  }

  exec { 'install-remediate':
    command   => $cmd,
    cwd       => $install_dir,
    logoutput => true,
    path      => ['C:/Program Files/Docker/'],
  }
}
