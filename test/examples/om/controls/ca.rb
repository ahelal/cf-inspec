# encoding: utf-8

require 'date'

control 'Check OM CA' do
  title 'should not expire in 2 months'
  describe om_certificates(2, 'm') do
    its(%w[active_root_ca issuer]) { should eq 'Pivotal' }
    its('expires') { should be_empty }
  end
end
