# encoding: utf-8

control 'OM vm extensions all loadbalancer' do
  describe om_vm_extensions do
    its('extentions') { should_not be_empty }
  end
end

control 'OM vm extensions tags A' do
  cp = { 'cloud_properties' => { 'tags' => %w[tag1 tag2 tag3] }, 'name' => 'A' }
  describe om_vm_extensions('A') do
    its('extentions') { should eq cp }
  end
end
