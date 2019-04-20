# encoding: utf-8

control 'OM Resource job' do
  title 'instance job PAS deigo-cell should match defined resources'
  describe om_resource_job('cf', 'diego_cell') do
    its('instances') { should eq 18 }
    its(%w[instance_type id]) { should eq '2xlarge.disk' }
    # its('additional_vm_extensions') { should eq %w[vm_ext_configure_load_balancer vm_ext_setting_additional_security_groups] }
  end
end
