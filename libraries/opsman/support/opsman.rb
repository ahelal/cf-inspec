require 'net/http'
require 'openssl'
require 'json'
require 'opsman/deployed_products'
require 'opsman/director_properties'
require 'opsman/info'
require 'opsman/products_properties'
require 'opsman/resource_jobs'
require 'opsman/stemcells'
require 'opsman/installations'
require 'opsman/info'
require 'opsman/certificates'
require 'opsman/vm_extensions'

class Opsman
  def initialize
    @om_target = ENV['OM_TARGET'] || raise('no OM_TARGET defined in environment')
    @om_username = ENV['OM_USERNAME']
    @om_password = ENV['OM_PASSWORD']
    @om_ssl_validation = ENV['OM_SKIP_SSL_VALIDATION'] || 'false'
    @access_token = ''
    @cache = RequestCache.new
  end

  def products(product_type)
    products = get('/api/v0/deployed/products')
    product_list = []
    products.each do |product|
      return product if product['type'] == product_type
      product_list.push(product['type'])
    end
    raise "error unknown product '#{product_type}' available products are #{product_list}"
  end

  def product_guid(product_type)
    product = products(product_type)
    return product['guid'] unless product.nil?
    nil
  end

  def job_guid(product_guid, job_name)
    jobs = get("/api/v0/staged/products/#{product_guid}/jobs")
    jobs_list = []
    jobs['jobs'].each do |job|
      return job['guid'] if job['name'] == job_name
      jobs_list.push(job['name'])
    end
    raise "error unknown job '#{job_name}' available jobs are #{jobs_list}"
  end

  def get(path, headers = {})
    id = @cache.encode(@om_target, path, headers)
    cache_result = @cache.get_cache(id)
    return cache_result if cache_result
    auth
    request = construct_http_client(@om_target)
    headers =  construct_get_headers(headers)
    response = request.get(path.to_s, headers)
    @cache.write_cache(id, response.body)
    JSON.parse(response.body)
  end

  private

  def construct_http_client(uri_string)
    uri_string = 'https://' + uri_string unless uri_string.start_with? 'http'

    uri = URI(uri_string)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = if @om_ssl_validation
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end
    http
  end

  def construct_get_headers(headers)
    headers[:Accept] = 'application/json'
    headers[:Authorization] = "Bearer #{@access_token}" unless @access_token.empty?
    headers
  end

  def auth
    return false unless @om_username && @om_password
    http = construct_http_client(@om_target.to_s)
    request = Net::HTTP::Post.new('/uaa/oauth/token')
    request.basic_auth('opsman', '')
    form = URI.encode_www_form('grant_type' => 'password', 'username' => @om_username, 'password' => @om_password)
    case response = http.request(request, form)
    when !Net::HTTPSuccess then
      raise "Authentication request failed. #{response.value}"
    end
    @access_token = JSON.parse(response.body)['access_token']
  end
end
