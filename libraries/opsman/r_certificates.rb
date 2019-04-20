require 'date'

class OmCertificate < Inspec.resource(1)
  name 'om_certificates'
  desc ''

  example "
      its(%w[active_root_ca issuer]) { should eq 'Pivotal' }
    its('expires') { should be_empty }
  "

  include ObjectTraverser

  attr_reader :params, :raw_content
  def initialize(number = 0, unit = false)
    @params = {}
    begin
      @opsman = Opsman.new
      @params['active_root_ca'] = parse_active_root_ca
      @number = number
      @unit = unit
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def expires
    raise "not a valid number #{@number}" unless @number > 0
    raise "not a valid unit #{@unit} accepts d,w,m,y" unless %w[d w m y].include? @unit
    @opsman.get("/api/v0/deployed/certificates?expires_within=#{@number}#{@unit}")['certificates']
  end

  def method_missing(*keys)
    # catch bahavior of rspec its implementation
    # @see https://github.com/rspec/rspec-its/blob/master/lib/rspec/its.rb#L110
    keys.shift if keys.is_a?(Array) && keys[0] == :[]
    value(keys)
  end

  def value(key)
    # uses ObjectTraverser.extract_value to walk the hash looking for the key,
    # which may be an Array of keys for a nested Hash.
    extract_value(key, params)
  end

  def parse_active_root_ca
    ca_response = @opsman.get('/api/v0/certificate_authorities')
    ca_response['certificate_authorities'].each do |ca|
      return ca if ca['active']
    end
    raise 'no active ca'
  end
end
