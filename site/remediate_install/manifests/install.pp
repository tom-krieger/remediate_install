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
# @param $kernel
#    OS Kernel like Windows or Linux
#
# @api private
class remediate_install::install (
  String $install_dir,
  String $license_file,
  String $compose_dir   = '',
  String $compose_url   = 'https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
  String $kernel = 'Linux',
) {
  if($kernel == 'Windows') {
    $inst_class = 'remediate_install::install::windows'
  } else {
    $inst_class = 'remediate_install::install::linux'
  }

  class { $inst_class:
    install_dir  => $install_dir,
    license_file => $license_file,
    compose_dir  => $compose_dir,
    compose_url  => $compose_url
  }
}
