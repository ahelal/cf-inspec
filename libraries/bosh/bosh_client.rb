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

  def get(path)
    response = bosh_api.get path

    JSON.parse(response.body)
  end

  private

  def bosh_director_url
    bosh_env = @bosh_environment.to_s
    bosh_env.start_with?(%r{http[s]?://}) ? bosh_env : 'https://' + bosh_env
  end

  def bosh_api
    Faraday.new(url: bosh_director_url, ssl: { ca_file: @ca_path }) do |faraday|
      faraday.port = 25_555
      # faraday.response :logger
      faraday.authorization :Bearer, access_token
      faraday.adapter Faraday.default_adapter
    end
  end

  def access_token
    return @access_token if @access_token

    conn = Faraday.new(url: bosh_director_url, ssl: { ca_file: @ca_path }) do |faraday|
      faraday.port = 8_443
      # faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    response = conn.post('/oauth/token', 'grant_type' => 'client_credentials',
                                         'client_id' => @bosh_client,
                                         'client_secret' => @bosh_client_secret)

    pp response

    @access_token = JSON.parse(response.body)['access_token']
  end
end
