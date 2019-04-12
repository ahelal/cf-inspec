
require 'pp'

class OmDeployedProduct < Inspec.resource(1)
  name 'om_deployed_product'
  desc ''

  example "
    describe om_deployed_product('pivotal-mysql') do
      its('version') { should match /2.4.4/ }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(product_type)
    @params = {}
    begin
      @opsman = Opsman.new
      product = @opsman.products(product_type)
      @params['version'] = product['product_version'] unless product.nil?
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
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
