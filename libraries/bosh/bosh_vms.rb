# require 'bosh_api'
require 'pp'

class BoshVms < Inspec.resource(1)
  name 'bosh_vms'
  desc "Verify info about a bosh deployment's vms"

  example "
    describe bosh_vms('cf-warden') do
      its('keys') { should contain '263.1.0' }
      its(['user_authentication','type']) { should eq 'uaa'}
      its(['user_authentication','options', 'url']) { should eq 'https://10.0.0.6:8443'}
      its(['features', 'dns', 'status']) { should be false }
      its(['features', 'dns', 'extras', 'domain_name']) { should eq 'bosh' }
    end
  "

  include ObjectTraverser

  attr_reader :params

  def initialize(deployment_name)
    @params = {}
    begin
      @bosh_client = BoshClient.new
      @params = @bosh_client.get("/deployments/#{deployment_name}/vms?format=full")
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "BOSH API error: #{e}"
    end
  end

  def for_job_matching(r)
    @params.select { |vm_stats| vm_stats['job_name'].match? r }
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
