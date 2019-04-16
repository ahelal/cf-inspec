# encoding: utf-8

control 'OM Deployed product PAS' do
  title 'should be deployed'
  describe om_deployed_product('cf') do
    its('version') { should match(/2.3.8/) }
  end
end

control 'OM Deployed product Pivotal mysql' do
  title 'should be deployed'
  describe om_deployed_product('pivotal-mysql') do
    its('version') { should match(/2.4.4/) }
  end
end
