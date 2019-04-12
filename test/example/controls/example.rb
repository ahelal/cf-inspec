# encoding: utf-8

title 'OM sample'

control 'OM version' do
  describe om_info do
    its('version') { should match /2.3/ }
  end
end

control 'Mysql tile' do
  describe om_deployed_product('cf') do
    its('version') { should match /2.4.4/ }
  end

  describe om_product_properties('pivotal-mysql') do
    its(['properties', '.properties.request_timeout', 'value']) { should eq 120 }
    its(['properties', '.properties.plan3_selector.active.name', 'value']) { should eq 'db-large' }
    its(['properties', '.properties.enable_lower_case_table_names', 'value']) { should eq false }
    its(['properties', '.properties.enable_tls_selector', 'value']) { should eq 'disabled' }
  end
end

control 'CF tile' do
  describe om_resource_job('cf', 'diego_cell') do
    its('instances') { should eq 10 }
    its('additional_vm_extensions') { should eq %w[vm_ext_configure_load_balancer vm_ext_setting_additional_security_groups] }
    its(%w[instance_type id]) { should eq 'm3.medium' }
  end
end
