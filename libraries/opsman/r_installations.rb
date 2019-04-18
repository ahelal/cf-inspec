require 'pp'

class OmInstallation < Inspec.resource(1)
  name 'om_installations'
  desc 'Verify installation data'

  include ObjectTraverser

  attr_reader :params, :raw_content

  def initialize(_path = nil)
    @params = {}
    begin
      @opsman = Opsman.new
      @installations = get_installations
    rescue => e
      raise Inspec::Exceptions::ResourceSkipped, "OM API error: #{e}"
    end
  end

  def status_of_last_run
    last_run["status"]
  end

  def status_of_last_completed_run
    last_completed_run["status"]
  end

  # {"user_name"=>"admin", "finished_at"=>"2019-04-18T14:02:44.410Z", 
                      #     "started_at"=>"2019-04-18T14:02:24.033Z", "status"=>"failed", "additions"=>[{"identifier"=>"p-bosh", "label"=>"BOSH Director", "product_version"=>"2.2-build.427", "deployment_status"=>"failed", "change_type"=>"addition", "guid"=>"p-bosh-cd338b266fae39920444"}], "deletions"=>[], "updates"=>[], "unchanged"=>[], "id"=>3}

  def duration_of_last_completed_run
    run = last_completed_run
    start = DateTime.parse(run["started_at"])
    stop = DateTime.parse(run["finished_at"])
    ((stop - start) * 24 * 60).to_i 
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

  def get_installations
    obj = @opsman.get('/api/v0/installations', 'Accept' => 'application/json')
    raise "Opsman has no installations." if obj['installations'].empty?
    obj['installations'] 
  end

  def last_run
    @installations[0]
  end

  def last_completed_run
    @installations.each do |installation|
      return installation if ['successful', 'failed'].include? installation['status']
    end
  end

end


