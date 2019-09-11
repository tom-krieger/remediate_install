require 'spec_helper'

describe 'remediate_install::firewall::linux::post' do
  test_on = {
    :supported_os => [
      {
        'operatingsystem'        => 'CentOS',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem'        => 'OracleLinux',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7', '8'],
      },
      {
        'operatingsystem'        => 'Scientific',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['8', '9'],
      },
      {
        'operatingsystem'        => 'Ubuntu',
        'operatingsystemrelease' => ['14.04', '16.04', '18.04'],
      },
    ],
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
