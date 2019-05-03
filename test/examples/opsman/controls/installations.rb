describe om_installations do
  its('status_of_last_run') { should eq 'succeeded' }
  its('status_of_last_completed_run') { should eq 'succeeded' }
  its('duration_of_last_completed_run') { should be < 60 * 60 }
end
