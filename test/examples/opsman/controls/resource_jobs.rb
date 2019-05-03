describe om_resource_jobs do
  its(%w[cf diego_cell instances]) { should eq 10 }
  its(%w[cf diego_cell additional_vm_extensions]) { should eq %w[vm_ext_configure_load_balancer vm_ext_setting_additional_security_groups] }
  its(%w[cf diego_cell instance_type id]) { should eq 'm3.medium' }
end
