# encoding: utf-8

control 'Check opsman' do
  title 'should be reachable'
  describe om_installations do
    its('status_of_last_run') { should eq 'completed' }
    its('status_of_last_completed_run') { should eq 'failed' }
    its('duration_of_last_completed_run') { should be < 60 * 60 }
  end
end
