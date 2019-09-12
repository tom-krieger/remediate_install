require 'spec_helper'

describe 'remediate_install::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os =~ %r{windows}
        let(:params) do
          {
            'install_dir' => 'c:/remediate',
            'license_file' => 'c:/license.json',
          }
        end
      else
        let(:params) do
          {
            'install_dir' => '/opt/remediate',
            'license_file' => '/tmp/license.json',
          }
        end
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
