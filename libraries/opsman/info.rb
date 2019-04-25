=begin
 name: om_info
 desc: |
        This resources returns version information of the Ops Manager.

 api:
   - https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#getting-information-about-ops-manager

 methods:
     - version: contains the opsman version.
     - raw_attribute: contains the raw api response.

 example: |
    control 'opsman should be reachable and using desired version' do
        describe bosh_info do
          its('version') { should match(/2.3/) }
        end
        describe bosh_info do
          its('version') { should eq 'v2.3.0-build.79' }
        end
        describe bosh_info do
          its('raw_content') { should include('info' => { 'version => match(/2.3/) }) }
        end
      end
=end

class OmInfo < Inspec.resource(1)
  name 'om_info'

  def initialize
    @opsman = Opsman.new
  end

  def version
    info = raw_content
    info['info']['version']
  end

  def raw_content
    @opsman.get('/api/v0/info')
  end
end
