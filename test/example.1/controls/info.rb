# encoding: utf-8

control 'Check opsman' do
  title 'should be reachable'
  describe om_info do
    its('version') { should match(/2.2/) }
  end
end
