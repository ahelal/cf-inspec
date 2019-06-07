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
    raise "GET failed (#{response.status}):\n\t#{response.body}" unless response.success?

    JSON.parse(response.body)
  end

  private

  def bosh_director_url
    bosh_env = @bosh_environment.to_s
    bosh_env.start_with?(%r{http[s]?://}) ? bosh_env : 'https://' + bosh_env
  end

  def bosh_api
    conn = Faraday.new(url: bosh_director_url, ssl: { ca_file: @ca_path }) do |f|
      f.use FaradayMiddleware::FollowRedirects, limit: 3
      f.adapter :net_http
    end
    conn.authorization :Bearer, access_token
    conn.port = 25_555
    conn
  end

  def access_token
    return @access_token if @access_token

    conn = Faraday.new(url: bosh_director_url, ssl: { ca_file: @ca_path })
    conn.port = 8_443

    response = conn.post('/oauth/token', 'grant_type' => 'client_credentials',
                                         'client_id' => @bosh_client,
                                         'client_secret' => @bosh_client_secret)

    raise "Access Token request failed (#{response.status}):\n\t#{response.body}" unless response.success?

    @access_token = JSON.parse(response.body)['access_token']
  end
end
