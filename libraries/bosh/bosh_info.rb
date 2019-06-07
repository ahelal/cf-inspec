# require 'bosh_api'
require 'pp'

class BoshInfo < Inspec.resource(1)
  name 'bosh_info'
  desc 'Verify info about bosh director version, user authentication or features'

  example "
    describe bosh_info do
      its('version') { should match '263.1.0' }
      its(['user_authentication','type']) { should eq 'uaa'}
      its(['user_authentication','options', 'url']) { should eq 'https://10.0.0.6:8443'}
      its(['features', 'dns', 'status']) { should be false }
      its(['features', 'dns', 'extras', 'domain_name']) { should eq 'bosh' }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(_path = nil)
    @params = {}
    begin
      @bosh_client = BoshClient.new
      @params = @bosh_client.get '/info'
    rescue => e
      puts "Error during processing: #{$ERROR_INFO}"
      puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

      raise Inspec::Exceptions::ResourceFailed, "BOSH API error: #{e}"
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
