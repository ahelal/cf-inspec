# encoding: utf-8

control 'OM product properties pivotal mysql' do
  title 'should be match required state'
  describe om_product_properties('pivotal-mysql') do
    its(['properties', '.properties.request_timeout', 'value']) { should eq 120 }
    its(['properties', '.properties.plan3_selector.active.name', 'value']) { should eq 'db-large' }
    its(['properties', '.properties.enable_lower_case_table_names', 'value']) { should eq false }
    its(['properties', '.properties.enable_tls_selector', 'value']) { should eq 'disabled' }
  end
end
