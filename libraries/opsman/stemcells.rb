=begin
 name: om_assigned_stemcells
 desc: |
        Check deployed VM extensions
 api:
   - https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#deployed-vm-extensions
 methods:
     - extensions: get all vm extensions without filters
     - extension: return a specific extension (must be supplied as an argument)
 example: |
    control 'Assigned PAS stemcell' do
      title 'should be pinned'
      describe om_assigned_stemcells('cf') do
        its('version') { should eq '97.74' }
      end
    end
    control 'All assigned stemcell' do
      title 'should be ubuntu xenial'
      describe om_assigned_stemcells do
        its('versions') { should all(include('97.')) }
      end
    end
=end

class OmStemcellsJob < Inspec.resource(1)
  name 'om_assigned_stemcells'

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(product_type = nil)
    @params = {}
    begin
      @opsman = Opsman.new
      @product_type = product_type
      @params = all_products_assignments if @product_type.nil?
      @params = single_product_assignment unless @product_type.nil?
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def all_products_assignments
    stemcell_assignments = assignments
    stemcell_list = []
    stemcell_assignments.each do |stemcell_assignment|
      stemcell_list.push(stemcell_assignment['staged_stemcell_version'])
    end
    { 'versions' => stemcell_list }
  end

  def single_product_assignment
    stemcell_assignments = assignments
    p_guid = @opsman.product_guid(@product_type)
    stemcell_assignments.each do |stemcell_assignment|
      return { 'version' => stemcell_assignment['staged_stemcell_version'] } if stemcell_assignment['guid'] == p_guid
    end
    raise "error unkown product '#{@product_type}'"
  end

  private

  def assignments
    stemcell_assignments = @opsman.get('/api/v0/stemcell_assignments')
    stemcell_assignments['products']
  end
end
