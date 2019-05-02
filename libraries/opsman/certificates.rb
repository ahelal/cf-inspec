=begin
 name: om_certificates
 desc: |
        Check information about certificates from products
 api:
   - https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#getting-information-about-certificates-from-products
 methods:
     - expires: boolean value if certificates will expire with selected criteria
 example: |
    describe om_certificates(1,'m') do
      its(%w[active_root_ca issuer]) { should eq 'Pivotal' }
      its('expires') { should be_empty }
    end
=end

require 'date'

class OmCertificate < Inspec.resource(1)
  name 'om_certificates'

  def initialize(number = 0, unit = false)
    @opsman = Opsman.new
    @number = number
    @unit = unit
  rescue => e
    raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
  end

  def expires
    raise "not a valid number #{@number}" unless @number > 0
    raise "not a valid unit #{@unit} accepts d,w,m,y" unless %w[d w m y].include? @unit
    @opsman.get("/api/v0/deployed/certificates?expires_within=#{@number}#{@unit}")['certificates']
  end

  def active_root_ca
    ca_response = @opsman.get('/api/v0/certificate_authorities')
    ca_response['certificate_authorities'].each do |ca|
      return ca if ca['active']
    end
    raise 'no active ca'
  end
end
