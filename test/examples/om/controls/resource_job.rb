# encoding: utf-8

control 'OM Resource jobs' do
  describe om_resource_jobs do
    its(['cf', 'diego_cell', 'instances']) { should eq 18 }
    its(%w[cf diego_cell instance_type id]) { should eq '2xlarge.disk' }
  end
end
