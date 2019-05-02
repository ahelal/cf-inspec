
class OmProductsProperties < Inspec.resource(1)
  name 'om_products_properties'

  example "
    describe om_products_properties do
      its(['pivotal-mysql', '.properties.plan3_selector.active.name', 'value']) { should eq 'db-large' }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize
    @params = {}
    begin
      @opsman = Opsman.new
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  private

  def method_missing(*keys)
    # catch bahavior of rspec its implementation
    # @see https://github.com/rspec/rspec-its/blob/master/lib/rspec/its.rb#L110
    keys.shift if keys.is_a?(Array) && keys[0] == :[]
    value(keys)
  end

  def value(key)
    raise 'om_products_properties must be indexed into by at least product (e.g. cf)' unless key.is_a?(Array) && key.length >= 1

    guid = @opsman.product_guid(key[0].to_s)
    properties = @opsman.get("/api/v0/staged/products/#{guid}/properties")['properties']

    if key.length == 1
      properties
    else
      # uses ObjectTraverser.extract_value to walk the hash looking for the key,
      # which may be an Array of keys for a nested Hash.
      extract_value(key[1..-1], properties)
    end
  end
end
