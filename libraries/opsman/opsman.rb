require 'net/http'
require 'openssl'
require 'json'
require 'base64'
require 'opsman/r_deployed_product'
require 'opsman/r_director_properties'
require 'opsman/r_info'
require 'opsman/r_product_properties'
require 'opsman/r_resource_job'
require 'opsman/r_stemcells'

class Opsman
  def initialize
    @om_target = ENV['OM_TARGET'] || raise('no OM_TARGET defined in environment')
    @om_username = ENV['OM_USERNAME']
    @om_password = ENV['OM_PASSWORD']
    @om_ssl_validation = ENV['OM_SKIP_SSL_VALIDATION'] || 'true'
    @cache_time = ENV['INSPEC_CACHE_TIME'] || ''
    @cache_dir = ENV['INSPEC_CACHE_DIR'] || "#{ENV['HOME']}/.inspec_cache"
    cache_setup
    @access_token = ''
    auth if @om_username && @om_password
  end

  def products(product_type)
    products = get('/api/v0/deployed/products', 'Accept' => 'application/json')
    product_list = []
    products.each do |product|
      return product if product['type'] == product_type
      product_list.push(product['type'])
    end
    raise "error unkown product '#{product_type}' avaiable products are #{product_list}"
  end

  def product_guid(product_type)
    product = products(product_type)
    return product['guid'] unless product.nil?
    nil
  end

  def job_guid(product_guid, job_name)
    jobs = get("/api/v0/staged/products/#{product_guid}/jobs", 'Accept' => 'application/json')
    jobs_list = []
    jobs['jobs'].each do |job|
      return job['guid'] if job['name'] == job_name
      jobs_list.push(job['name'])
    end
    raise "error unkown job '#{job_name}' avaiable jobs are #{jobs_list}"
  end

  def get(path, headers = {})
    cache_id = Base64.encode64(@om_target.to_s + path)
    cache = get_cache(cache_id)
    return cache if cache
    uri = URI.parse(@om_target.to_s)
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_PEER
    headers['Authorization'] = "Bearer #{@access_token}" unless @access_token.empty?
    case response = request.get(path.to_s, headers)
    when Net::HTTPSuccess then
      write_cache(cache_id, response.body)
      JSON.parse(response.body)
    else
      raise(response.value)
    end
  end

  private

  def auth
    uri = URI.parse(@om_target.to_s)
    uri.path = '/uaa/oauth/token'
    uri.user = 'opsman'

    case response = Net::HTTP.post_form(uri, 'grant_type' => 'password', 'username' => @om_username, 'password' => @om_password)
    when Net::HTTPSuccess then
      decoded = JSON.parse(response.body)
      @access_token = decoded['access_token']
    else
      raise(response.value)
    end
  end

  def cache_setup
    Dir.mkdir @cache_dir unless @cache_time.empty? || File.exist?(@cache_dir)
  end

  def get_cache(id)
    return false if @cache_time.empty?
    cache_file_path = "#{@cache_dir}/#{id}.json"
    return false unless File.file?(cache_file_path)
    diff_seconds = (Time.new - File.stat(cache_file_path).ctime).to_i
    return false if diff_seconds > @cache_time.to_i
    f = File.open(cache_file_path)
    JSON.parse(f.read)
  end

  def write_cache(id, contet)
    return false if @cache_time.empty?
    cache_file_path = "#{@cache_dir}/#{id}.json"
    File.write(cache_file_path, contet)
  end
end
