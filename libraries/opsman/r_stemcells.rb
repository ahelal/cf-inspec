
require 'pp'

class OmStemcellsJob < Inspec.resource(1)
  name 'om_assigned_stemcells'
  desc ''

  example "
    describe om_assigned_stemcells('cf') do
      its('version') { should eq '97.57' }
    end
    describe om_assigned_stemcells do
      its('versions') { should all(include('97.')) }
    end
  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(product_type = nil)
    @params = {}
    begin
      @opsman = Opsman.new
      @product_type = product_type
      @params = product_stemcell
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def product_stemcell
    stemcell_assignments = @opsman.get('/api/v0/stemcell_assignments', 'Accept' => 'application/json')
    stemcell_assignments = stemcell_assignments['products']

    if @product_type.nil?
      stemcell_list = []
      stemcell_assignments.each { |stemcell_assignment| stemcell_list.push(stemcell_assignment['staged_stemcell_version']) }
      return { 'versions' => stemcell_list }
    end

    p_guid = @opsman.product_guid(@product_type)
    stemcell_assignments.each do |stemcell_assignment|
      return { 'version' => stemcell_assignment['staged_stemcell_version'] } if stemcell_assignment['guid'] == p_guid
    end
    raise "error unkown product '#{@product_type}'"
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
