require 'spec_helper'

describe 'remediate_install::install::linux::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          'install_dir' => '/opt/remediate',
          'compose_dir' => '/usr/local/bin',
        }
      end

      it { is_expected.to compile }
    end
  end
end
