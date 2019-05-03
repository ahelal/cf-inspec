describe om_certificates(1, 'm') do
  its(%w[active_root_ca issuer]) { should eq 'Pivotal' }
  its('expires') { should be_empty }
end
