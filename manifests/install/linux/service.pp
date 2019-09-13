# @summary 
#    Install a service for remediate
#
# Creates a systemd service for remediate
#
# @param install_dir
#    Directory where Remediate is installed
#
# @param compose_dir
#    Directory where docker composye is installed
#
# @example
#   include remediate_install::service
#
# @api private
class remediate_install::install::linux::service (String $install_dir, String $compose_dir) {
  if($facts['os']['family'] == 'RedHat') {
    $start = "cd ${install_dir} ; ${compose_dir}/docker-comnpose run remediate start"
    $stop = "cd ${install_dir} ; ${compose_dir}/docker-comnpose run remediate stop"

    file { '/etc/systemd/system/remediate.service':
      ensure  => file,
      content => epp('remediate_install/remediate_systemd_service.epp',
                      { 'startcommand' => $start,
                        'stopcommand'  => $stop}
                  ),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }

    service { 'remediate':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/remediate.service'],
    }
  }
}
