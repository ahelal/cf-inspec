=begin
 name: om_director_properties
 desc: |
        Fetching director, IaaS, and security properties
 api:
   - https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#staged-bosh-director
 methods:
     - director_properties: get all bosh director properties.
 example: |
    describe om_director_properties do
      its(%w[iaas_configuration encrypted]) { should eq true }
      its(%w[director_configuration ntp_servers_string]) { should eq 'us.pool.ntp.org, time.google.com' }
      its(%w[iaas_configuration tls_enabled]) { should eq true }
      its(%w[syslog_configuration enabled]) { should eq true }
    end
=end

class OmDirectorProperties < Inspec.resource(1)
  name 'om_director_properties'

  attr_reader :params

  def initialize
    @opsman = Opsman.new
    @params = director_properties
  rescue => e
    raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
  end

  def director_properties
    @opsman.get('/api/v0/staged/director/properties')
  end
end
