require 'spec_helper'

describe 'remediate_install::firewall::windows' do
  test_on = {
    :supported_os => [
      {
        'operatingsystem'        => 'windows',
        'operatingsystemrelease' => ['2019', '10'],
      },
    ],
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          'operatingsystemversion' => 'windows',
          'os' => {
            'windows' => {
              'system32' => 'c:\windows\system32',
            },
          },
        )
      end

      it { is_expected.to compile }
    end
  end
end
