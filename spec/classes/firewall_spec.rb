require 'spec_helper'

describe 'remediate_install::firewall' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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

      it { is_expected.to compile }
    end
  end
end
