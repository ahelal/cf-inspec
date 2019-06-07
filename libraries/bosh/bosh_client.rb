require 'net/http'
require 'openssl'
require 'json'
require 'faraday'
require 'bosh/bosh_deployments'
require 'bosh/bosh_info'
require 'bosh/bosh_vms'

class BoshClient
  def initialize
    @bosh_client = ENV['BOSH_CLIENT'] || raise('no BOSH_CLIENT defined')
    @bosh_client_secret = ENV['BOSH_CLIENT_SECRET'] || raise('no BOSH_CLIENT_SECRET defined')
    @bosh_environment = ENV['BOSH_ENVIRONMENT'] || raise('no BOSH_ENVIRONMENT defined')
    @bosh_ca_cert = ENV['BOSH_CA_CERT']
    @access_token = nil
    @ca_path = '/tmp/bosh_ca_cert.pem'

    File.open(@ca_path, 'w') { |file| file.write(@bosh_ca_cert) } if @bosh_ca_cert
  end

  def get(path, redirects_remaining = 3)
    raise 'too many redirects' if redirects_remaining.zero?

    response = http_client(25_555).get(path, Authorization: "Bearer #{access_token}")
    case response
    when Net::HTTPSuccess then
      JSON.parse(response.body)
    when Net::HTTPRedirection then
      get(response['location'], redirects_remaining - 1)
    else
      response.error!
    end
  end

  private

  def http_client(port)
    bosh_env = @bosh_environment.to_s
    bosh_env = 'https://' + bosh_env unless bosh_env.start_with? %r{http[s]?://}
    uri = URI(bosh_env)
    http = Net::HTTP.new(uri.host, port)
    http.use_ssl = uri.scheme == 'https'
    http.ca_file = File.path(@ca_path) unless @bosh_ca_cert.nil?
    http
  end

  def access_token
    return @access_token if @access_token

    request = Net::HTTP::Post.new('/oauth/token')
    body = URI.encode_www_form('grant_type' => 'client_credentials',
                               'client_id' => @bosh_client,
                               'client_secret' => @bosh_client_secret)

    case response = http_client(8_443).request(request, body)
    when Net::HTTPSuccess then
      @access_token = JSON.parse(response.body)['access_token']
    else
      response.error!
    end
  end
end
