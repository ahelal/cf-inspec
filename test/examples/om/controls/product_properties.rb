# encoding: utf-8

control 'OM products properties' do
  describe om_products_properties do
    its(['pivotal-mysql', '.properties.plan3_selector.active.name', 'value']) { should eq 'db-large' }
    its(['pivotal-mysql', '.properties.request_timeout', 'value']) { should eq 120 }
    its(['pivotal-mysql', '.properties.enable_lower_case_table_names', 'value']) { should eq false }
    its(['pivotal-mysql', '.properties.enable_tls_selector', 'value']) { should eq 'disabled' }
  end
end
