
require 'pp'

class OmResourceJob < Inspec.resource(1)
  name 'om_resource_job'
  desc ''

  example "
    describe om_deployed_product('pivotal-mysql') do
      its('product_version') { should match /2.4.4/ }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(product_type, job_name)
    @params = {}
    begin
      @opsman = Opsman.new
      @product_type = product_type
      @job_name = job_name
      @params = product_resources
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def product_resources
    p_guid = @opsman.product_guid(@product_type)
    job_guid = @opsman.job_guid(p_guid, @job_name)

    response = @opsman.get("/api/v0/staged/products/#{p_guid}/jobs/#{job_guid}/resource_config",
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
