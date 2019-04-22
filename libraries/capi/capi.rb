require 'net/http'
require 'openssl'
require 'json'
require 'base64'
require 'capi/r_info'
require 'capi/r_orgs'

class CAPI
  attr_reader :info
  def initialize
    @cf_target = ENV['CF_TARGET'] || raise('no CF_TARGET defined in environment')
    @cf_ssl_validation = ENV['CF_SKIP_SSL_VALIDATION'] || 'false'
    @cache = RequestCache.new
    @cf_username = ENV['CF_USERNAME']
    @cf_password = ENV['CF_PASSWORD']
    @access_token = ''
    @info = get('/v2/info', {}, false)
  end

  def get(path, headers = {}, do_auth = true, uri = @cf_target)
    id = @cache.encode(@cf_target, path, headers)
    cache_result = @cache.get_cache(id)
    return cache_result if cache_result
    auth if do_auth
    request = construct_http_client(uri)
    headers = construct_get_headers(headers)
    response = next_page(request, path, headers)
    @cache.write_cache(id, response.to_json)
    response
  end

  private

  def next_page(request, path, headers)
    content = simple_get(request, path, headers)
    until content['next_url'].nil?
      new_content = simple_get(request, content['next_url'], headers)
      new_content['resources'] = new_content['resources'].concat(content['resources'])
      content = new_content
    end
    content
  end

  def simple_get(request, path, headers)
    response = request.get(path.to_s, headers)
    raise "get request failed. #{response.value}" unless response.is_a? Net::HTTPSuccess
    JSON.parse(response.body)
  end

  def construct_http_client(uri_string)
    uri = URI.parse(uri_string)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = if @cf_ssl_validation
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

  def auth_url
    login_url = get('/login', {}, false, @info['authorization_endpoint'])
    login_url['links']['login']
  end

  def auth
    return false unless @cf_username && @cf_password
    http = construct_http_client(auth_url)
    request = Net::HTTP::Post.new('/oauth/token')
    request.basic_auth('cf', '')
    form = URI.encode_www_form('grant_type' => 'password', 'username' => @cf_username, 'password' => @cf_password)
    response = http.request(request, form)
    raise "Authentication request failed. #{response.value}" unless response.is_a? Net::HTTPSuccess
    body = JSON.parse(response.body)
    @access_token = body['access_token']
  end
end
