require_relative '../spec_helper'
require 'inspec'
require 'bosh/bosh_client'

context 'bosh_deployments' do
  before do
    ENV['BOSH_ENVIRONMENT'] = 'fake-bosh-director-url'
    ENV['BOSH_CLIENT'] = 'admin'
    ENV['BOSH_CLIENT_SECRET'] = 'secret'
    allow_any_instance_of(BoshClient).to receive(:get).with('/deployments').and_return(deployments_response)
  end

  it 'returns the list of deployments' do
    deployments = BoshDeployments.new
    expect(deployments.params.keys).to contain_exactly 'cf-warden'
    expect(deployments.deployment_names).to contain_exactly 'cf-warden'
    expect(deployments.send(:[], 'cf-warden', 'releases', 0, 'name')).to eq 'cf'
    expect(deployments.send(:[], 'cf-warden')).to include('releases' => include(include('name' => 'cf')))
  end

  let(:deployments_response) do
    JSON.parse(<<-JSON)
      [
        {
          "name": "cf-warden",
          "cloud_config": "none",
          "releases": [
            {
              "name": "cf",
              "version": "222"
            },
            {
              "name": "cf",
              "version": "223"
            }
          ],
          "stemcells": [
            {
              "name": "bosh-warden-boshlite-ubuntu-trusty-go_agent",
              "version": "2776"
            },
            {
              "name": "bosh-warden-boshlite-ubuntu-trusty-go_agent",
              "version": "3126"
            }
          ]
        }
      ]
    JSON
  end
end
