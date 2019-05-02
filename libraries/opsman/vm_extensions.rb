=begin
 name: om_vm_extensions
 desc: |
        Check deployed VM extensions
 api:
   - https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#deployed-vm-extensions
 methods:
     - extensions: get all vm extensions without filters
     - extension: return a specific extension (must be supplied as an argument)
 example: |
    control 'OM vm extensions all loadbalancer' do
      describe om_vm_extensions do
        its('extensions') { should_not be_empty }
      end
    end
    control 'OM vm extensions tags A' do
      cp = { 'cloud_properties' => { 'tags' => %w[tag1 tag2 tag3] }, 'name' => 'A' }
      describe om_vm_extensions('EXT_A') do
        its('extension') { should eq cp }
      end
    end
=end

class VMExtensions < Inspec.resource(1)
  name 'om_vm_extensions'

  def initialize(extension_name = false)
    @opsman = Opsman.new
    @extension_name = extension_name
  rescue => e
    raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
  end

  def extension
    extensions_list = []
    extensions.each do |ext|
      return ext if ext['name'] == @extension_name
      extensions_list.push(ext['name'])
    end
    raise "error unknown extension '#{@extension_name}' available extensions are #{extensions_list}"
  end

  def extensions
    obj = @opsman.get('/api/v0/deployed/vm_extensions')
    obj['vm_extensions']
  end
end
