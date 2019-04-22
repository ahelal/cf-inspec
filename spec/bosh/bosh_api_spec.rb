require_relative '../spec_helper'
require 'bosh/bosh_api'

describe 'Bosh client no env set' do
  it 'an exception is raised' do
    expect { BoshAPI.new }.to raise_error(RuntimeError)
  end
end

describe 'Bosh client env set' do
  describe 'when BOSH_ALL_PROXY is not set' do
    before(:all) do
      ENV['BOSH_ALL_PROXY'] = ''
    end
    it 'should not use ssh proxy' do
      expect(parse_bosh_proxy).to eq(false)
    end
  end
  describe 'when BOSH_ALL_PROXY is set' do
    before(:all) do
      ENV['BOSH_ALL_PROXY'] = 'ssh+socks5://jumpbox@somehost.com:22?private-key=/tmp/file.key'
    end
    it 'should use ssh proxy' do
      match_results = parse_bosh_proxy
      expect(match_results[:user]).to eq('jumpbox')
      expect(match_results[:host]).to eq('somehost.com')
      expect(match_results[:port]).to eq('22')
      expect(match_results[:key]).to eq('/tmp/file.key')
    end
  end
end
