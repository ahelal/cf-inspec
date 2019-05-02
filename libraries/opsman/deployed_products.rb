
class OmDeployedProducts < Inspec.resource(1)
  name 'om_deployed_products'

  example "
    describe om_deployed_products do
      its(['pivotal-mysql', 'version']) { should match /2.4.4/ }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize
    @params = {}
    begin
      @opsman = Opsman.new
      products = @opsman.get('/api/v0/deployed/products')
      @params = products.map { |product| [product['type'], product] }.to_h
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
