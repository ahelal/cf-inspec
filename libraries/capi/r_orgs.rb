
class CAPIOrgs < Inspec.resource(1)
  name 'capi_orgs'
  desc 'Verify orgs about capi'

  example "
    describe capi_orgs do
      its('version') { should match /2.120/ }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(org = nil)
    @params = {}
    begin
      @capi = CAPI.new(true)
      @selected_org = org
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "CAPI error: #{e}"
    end
  end

  def orgs
    un_filtered_orgs = @capi.get('/v2/organizations', {}, true)
    orgs_list = []
    un_filtered_orgs['resources'].each do |org|
      orgs_list.push(org['entity']['name'])
    end
    puts "org length #{orgs_list.length}"
    orgs_list
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
