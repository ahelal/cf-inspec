describe om_director_properties do
  its(%w[iaas_configuration encrypted]) { should eq true }
  its(%w[director_configuration ntp_servers_string]) { should eq 'us.pool.ntp.org, time.google.com' }
  its(%w[iaas_configuration tls_enabled]) { should eq true }
  its(%w[syslog_configuration enabled]) { should eq true }
end
