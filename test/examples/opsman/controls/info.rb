control 'opsman should be reachable and using desired version' do
  describe bosh_info do
    its('version') { should match(/2.3/) }
  end
  describe bosh_info do
    its('version') { should eq 'v2.3.0-build.79' }
  end
  describe bosh_info do
    its('raw_content') { should include('info' => { 'version' => match(/2.3/) }) }
  end
end
