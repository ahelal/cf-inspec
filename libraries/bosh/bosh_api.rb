require 'net/http'
require 'openssl'
require 'json'

class BoshClient
  def initialize
    @bosh_client = ENV['BOSH_CLIENT'] || raise('no BOSH_CLIENT defined')
    @bosh_client_secret = ENV['BOSH_CLIENT_SECRET'] || raise('no BOSH_CLIENT_SECRET defined')
    @bosh_environment = ENV['BOSH_ENVIRONMENT'] || raise('no BOSH_ENVIRONMENT defined')
    @bosh_ca_cert = ENV['BOSH_CA_CERT'] || raise('no BOSH_CA_CERT defined')
  end

  def info
    response = get('/info', 'Accept' => 'application/json')
    JSON.parse(response.body)
  end

  private

  def get(path, headers = {})
    uri = URI.parse(@bosh_environment.to_s)
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request.ca_file = @bosh_ca_cert
    response = request.get(path.to_s, headers)
    raise('got a bad response code from BOSH API call') unless response.code != 200
    response
  end
end
