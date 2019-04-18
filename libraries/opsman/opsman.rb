require 'net/http'
require 'openssl'
require 'json'
require 'opsman/api_cache'
require 'base64'
require 'opsman/r_deployed_product'
require 'opsman/r_director_properties'
require 'opsman/r_info'
require 'opsman/r_product_properties'
require 'opsman/r_resource_job'
require 'opsman/r_stemcells'
require 'opsman/r_installations'

class Opsman
  def initialize
    @om_target = ENV['OM_TARGET'] || raise('no OM_TARGET defined in environment')
    @om_username = ENV['OM_USERNAME']
    @om_password = ENV['OM_PASSWORD']
    @om_ssl_validation = ENV['OM_SKIP_SSL_VALIDATION'] || 'false'
    @access_token = ''
    auth if @om_username && @om_password
    @cache = RequestCache.new
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
    cache_result = @cache.get_cache(cache_id)
    return cache_result if cache_result

    headers['Accept'] = 'application/json'
    headers['Authorization'] = "Bearer #{@access_token}" unless @access_token.empty?
    case response = construct_http_client(@om_target.to_s).get(path.to_s, headers)
    when Net::HTTPSuccess then
      @cache.write_cache(cache_id, response.body)
      JSON.parse(response.body)
    else
      raise("Get request failed #{path}", response.value)
    end
  end

  private

  def construct_http_client(uri_string)
    uri = URI.parse(uri_string)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = if @om_ssl_validation
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end
    http
  end

  def auth
    http = construct_http_client(@om_target.to_s)
    request = Net::HTTP::Post.new('/uaa/oauth/token')
    request.basic_auth('opsman', '')
    post_data = URI.encode_www_form('grant_type' => 'password', 'username' => @om_username, 'password' => @om_password)
    response = http.request(request, post_data)
    case response
    when Net::HTTPSuccess then
      decoded = JSON.parse(response.body)
      @access_token = decoded['access_token']
    else
      raise('Error auth: ', response.value)
    end
  end
end
