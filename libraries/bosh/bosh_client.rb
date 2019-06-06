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
  end

  def get(path, headers = {})
    http = construct_http_client(@bosh_environment.to_s)
    request = Net::HTTP::Get.new(path, headers)
    request.basic_auth(@bosh_client, @bosh_client_secret)
    response = http.request(request)
    raise('got a bad response code from BOSH API call') unless response.code != 200
    JSON.parse(response.body)
  end

  private

  def construct_http_client(uri_string)
    uri_string = 'https://' + uri_string unless uri_string.start_with? 'http'

    uri = URI(uri_string)

    http = Net::HTTP.new(uri.host, 25_555)
    http.use_ssl = uri.scheme == 'https'
    http.verify_mode = if @om_ssl_validation
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end
    if @bosh_ca_cert
      file = Tempfile.new('bosh_ca_cert')
      begin
        file.write(@bosh_ca_cert)
      ensure
        file.close
      end
      http.ca_file = file
    end

    http
  end
end
