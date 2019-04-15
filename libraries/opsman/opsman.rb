require 'net/http'
require 'openssl'
require 'json'
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
    @access_token = ''
    auth if @om_username && @om_password
  end

  def products(product_type)
    response = get('/api/v0/deployed/products', 'Accept' => 'application/json')
    product_list = []
    products = JSON.parse(response.body)
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
    response = get("/api/v0/staged/products/#{product_guid}/jobs", 'Accept' => 'application/json')
    jobs_list = []
    jobs = JSON.parse(response.body)
    jobs['jobs'].each do |job|
      return job['guid'] if job['name'] == job_name
      jobs_list.push(job['name'])
    end
    raise "error unkown job '#{job_name}' avaiable jobs are #{jobs_list}"
  end

  def get(path, headers = {})
    uri = URI.parse(@om_target.to_s)
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_PEER
    headers['Authorization'] = "Bearer #{@access_token}" unless @access_token.empty?
    case response = request.get(path.to_s, headers)
    when Net::HTTPSuccess then
      response
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
end
