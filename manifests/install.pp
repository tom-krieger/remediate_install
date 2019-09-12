# @summary
#    Install Puppet remedeiate docker containers
#
# @param $install_dir
#   Directory where to install Remediate
#
# @param $license_file
#    Full qualified filename of the license file including path
#
# @param $compose_dir 
#    Directory where to install docker-compose binary
#
# @param $compose_url
#    URL of the Remediar docker compose file
#
# @api private
class remediate_install::install (
  String $install_dir,
  String $license_file,
  String $compose_dir   = '',
  String $compose_url   = 'https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
) {
  class { "remediate_install::install::${facts['kernel'].downcase()}":
    install_dir  => $install_dir,
    license_file => $license_file,
    compose_dir  => $compose_dir,
    compose_url  => $compose_url
  }
}
