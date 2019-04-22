# encoding: utf-8

control 'Check ORGS' do
  title 'should have '
  describe capi_orgs do
    its('orgs') { should match('x') }
  end
end
