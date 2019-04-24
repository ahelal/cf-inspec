
class OmResourceJobs < Inspec.resource(1)
  name 'om_resource_jobs'
  desc ''

  example "
    describe om_resource_jobs('cf', 'diego_cell') do
      its(['cf', 'diego_cell', 'instances']) { should eq 10 }
      its(['cf', 'diego_cell', 'additional_vm_extensions']) { should eq %w[vm_ext_configure_load_balancer vm_ext_setting_additional_security_groups] }
      its(['cf', 'diego_cell', 'instance_type', 'id']) { should eq 'm3.medium' }
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

  def product_resources
    p_guid = @opsman.product_guid(@product_type)
    job_guid = @opsman.job_guid(p_guid, @job_name)

    @opsman.get("/api/v0/staged/products/#{p_guid}/jobs/#{job_guid}/resource_config")
  end

  def method_missing(*keys)
    # catch bahavior of rspec its implementation
    # @see https://github.com/rspec/rspec-its/blob/master/lib/rspec/its.rb#L110
    keys.shift if keys.is_a?(Array) && keys[0] == :[]
    value(keys)
  end

  def value(key)
    raise 'om_resource_job must be indexed into by at least product and job (e.g. cf, diego_cell)' unless key.is_a?(Array) && key.length >= 2

    p_guid = @opsman.product_guid(key[0])
    job_guid = @opsman.job_guid(p_guid, key[1])
    resource_config = @opsman.get("/api/v0/staged/products/#{p_guid}/jobs/#{job_guid}/resource_config")

    if key.length == 2
      resource_config
    else
      # uses ObjectTraverser.extract_value to walk the hash looking for the key,
      # which may be an Array of keys for a nested Hash.
      extract_value(key[2..-1], resource_config)
    end
  end
end
