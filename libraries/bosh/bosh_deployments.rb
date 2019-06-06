# require 'bosh_api'
require 'pp'

class BoshDeployments < Inspec.resource(1)
  name 'bosh_deployments'
  desc 'Verify info about bosh deployments'

  example "
    describe bosh_deployments do
      its('keys') { should contain '263.1.0' }
      its(['user_authentication','type']) { should eq 'uaa'}
      its(['user_authentication','options', 'url']) { should eq 'https://10.0.0.6:8443'}
      its(['features', 'dns', 'status']) { should be false }
      its(['features', 'dns', 'extras', 'domain_name']) { should eq 'bosh' }
    end
  "

  include ObjectTraverser

  attr_reader :params

  def initialize
    @params = {}
    begin
      @bosh_client = BoshClient.new
      @params = @bosh_client.get('/deployments?exclude_configs=true')
                            .group_by { |d| d['name'] }
                            .each_with_object({}) { |(k, v), h| h[k] = v.first }
    rescue => e
      puts "Error during processing: #{$ERROR_INFO}"
      puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

      raise Inspec::Exceptions::ResourceSkipped, "BOSH API error: #{e}"
    end
  end

  def deployment_names
    @params.keys
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
