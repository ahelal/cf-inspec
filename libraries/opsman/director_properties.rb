
class OmDirectorProperties < Inspec.resource(1)
  name 'om_director_properties'
  desc ''

  example "
  describe om_director_properties do
    its(%w[iaas_configuration encrypted]) { should eq true }
    its(%w[director_configuration ntp_servers_string]) { should eq 'us.pool.ntp.org, time.google.com' }
    its(%w[iaas_configuration tls_enabled]) { should eq true }
    its(%w[syslog_configuration enabled]) { should eq true }
  end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize
    @params = {}
    begin
      @opsman = Opsman.new
      @params = director_properties
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def director_properties
    @opsman.get('/api/v0/staged/director/properties')
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
end
