
require 'net/ssh/gateway'
require 'net/http'

class SSHProxy
  def initialize(host, username, proxy_setup, keyfile = false, password = false)
    @host = host
    @username = username
    @keyfile = keyfile
    @password = password
    ports = proxy_setup.split(':')
    @remote_port = ports[0]
    @local_port = ports[1]
    @proxy_port = nil
    @gateway = nil
    start_proxy
  end

  def close
    @gateway.close(@proxy_port)
  end

  private

  def start_proxy
    options = {}
    options[:password] = @password if @password
    options[:keys] = [@keyfile] if @keyfile
    @gateway = Net::SSH::Gateway.new(@host, @username, options)
    @proxy_port = @gateway.open('localhost', @remote_port, @local_port)
    true
  end
end
