require 'net/http'
require 'openssl'
require 'json'
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
  end

  def get(path)
    authorize unless @access_token
    http = construct_http_client(@bosh_environment.to_s)
    request = Net::HTTP::Get.new(path, Authorization: "Bearer #{@access_token}")
    request.basic_auth(@bosh_client, @bosh_client_secret)
    response = http.request(request)
    raise('got a bad response code from BOSH API call') unless response.code != 200
    JSON.parse(response.body)
  end

  private

  def construct_http_client(uri_string, port = 25_555)
    uri_string = 'https://' + uri_string unless uri_string.start_with? 'http'

    uri = URI(uri_string)

    http = Net::HTTP.new(uri.host, port)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    if @bosh_ca_cert
      ca_path = '/tmp/bosh_ca_cert.pem'
      File.open(ca_path, 'w') { |file| file.write(@bosh_ca_cert) }
      http.ca_file = File.path(ca_path)
    end

    http
  end

  def authorize
    http = construct_http_client(@bosh_environment.to_s, 8_443)
    request = Net::HTTP::Post.new('/oauth/token')
    form = URI.encode_www_form('grant_type' => 'client_credentials',
                               'client_id' => @bosh_client,
                               'client_secret' => @bosh_client_secret)
    case response = http.request(request, form)
    when !Net::HTTPSuccess then
      raise "Authentication request failed. #{response.value}"
    end
    @access_token = JSON.parse(response.body)['access_token']
  end
end
