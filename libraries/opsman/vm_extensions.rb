
class VMExtensions < Inspec.resource(1)
  name 'om_vm_extensions'
  desc 'Verify info about vm_extensions'

  example "

  "

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(extention_name = false)
    @params = {}
    begin
      @opsman = Opsman.new
      @extention_name = extention_name
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def extentions
    exts = all_extentions
    return exts unless @extention_name

    exts.each do |ext|
      return ext if ext['name'] == @extention_name
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

  private

  def all_extentions
    obj = @opsman.get('/api/v0/deployed/vm_extensions')
    obj['vm_extensions']
  end
end
