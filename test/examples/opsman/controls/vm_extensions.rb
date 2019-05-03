control 'OM vm extensions all loadbalancer' do
  describe om_vm_extensions do
    its('extensions') { should_not be_empty }
  end
end
control 'OM vm extensions tags A' do
  cp = { 'cloud_properties' => { 'tags' => %w[tag1 tag2 tag3] }, 'name' => 'A' }
  describe om_vm_extensions('EXT_A') do
    its('extension') { should eq cp }
  end
end
