# encoding: utf-8

control 'Assigned PAS stemcell' do
  title 'should be pinned'
  describe om_assigned_stemcells('cf') do
    its('version') { should eq '97.74' }
  end
end

control 'All assigned stemcell' do
  title 'should be ubuntu xenial'
  describe om_assigned_stemcells do
    its('versions') { should all(include('97.')) }
  end
end
