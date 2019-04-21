# encoding: utf-8

control 'Check opsman' do
  title 'should be reachable'
  describe capi_info do
    its('api_version') { should match(/2.*/) }
  end
end
