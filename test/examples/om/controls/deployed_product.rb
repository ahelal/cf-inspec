# encoding: utf-8

control 'OM Deployed products' do
  describe om_deployed_products do
    its(['cf', 'product_version']) { should eq '2.3.9' }
  end

  describe om_deployed_product('pivotal-mysql') do
    its('pivotal-mysql') { should include('product_version' => match(/2.4.4/)) }
  end
end
