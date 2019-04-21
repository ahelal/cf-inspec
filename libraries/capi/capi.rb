require 'net/http'
require 'openssl'
require 'json'
require 'base64'
require 'capi/r_info'

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

  def get(path, headers = {}, auth = true)
    cache_result = @cache.get_cache(Base64.encode64(@cf_target.to_s + path))
    return cache_result if cache_result
    auth if @cf_username && @cf_password && auth
    case response = construct_http_client(@cf_target.to_s).get(path.to_s, construct_get_headers(headers))
    when Net::HTTPSuccess then
      @cache.write_cache(Base64.encode64(@cf_target.to_s + path), response.body)
      return JSON.parse(response.body)
    end
    raise "Get request failed #{path}. #{response.value}"
  end

  private

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

  def auth
    http = construct_http_client(@cf_target.to_s)
    request = Net::HTTP::Post.new('/uaa/oauth/token')
    request.basic_auth('opsman', '')
    response = http.request(request, URI.encode_www_form('grant_type' => 'password', 'username' => @cf_username, 'password' => @cf_password))
    case response
    when Net::HTTPSuccess then
      @access_token = JSON.parse(response.body)['access_token']
      return
    end
    raise "Authentication request failed. #{response.value}"
  end
end
