
require 'pp'

class OmProductproperties < Inspec.resource(1)
  name 'om_product_properties'
  desc ''

  example "
    describe om_deployed_product('pivotal-mysql') do
      its('product_version') { should match /2.4.4/ }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(product_type)
    @params = {}
    begin
      @opsman = Opsman.new
      @product_type = product_type
      @params = product_properties
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def product_properties
    guid = @opsman.product_guid(@product_type)
    return nil if guid.nil?
    response = @opsman.get("/api/v0/staged/products/#{guid}/properties",
                           'Accept' => 'application/json')
    JSON.parse(response.body)
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
