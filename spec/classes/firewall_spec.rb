require 'spec_helper'

describe 'remediate_install::firewall' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          'operatingsystemversion' => 'windows',
          'os' => {
            'windows' => {
              'system32' => 'c:/windows/system32',
            },
          },
        )
      end

      if os =~ %r{windows}
        let(:params) do
          {
            'kernel' => 'Windows',
          }
        end
      else
        let(:params) do
          {
            'kernel' => 'Linux',
          }
        end
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
