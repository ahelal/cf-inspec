# encoding: utf-8

control 'Check opsman' do
  title 'should be reachable'
  describe om_info do
    its('version') { should match(/2.3/) }
    its('last_completed_run') { should match(/2.3/) }
  end
end
