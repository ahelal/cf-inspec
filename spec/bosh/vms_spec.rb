require_relative '../spec_helper'
require 'inspec'
require 'bosh/bosh_client'

context 'bosh_deployments' do
  before do
    ENV['BOSH_ENVIRONMENT'] = 'fake-bosh-director-url'
    ENV['BOSH_CLIENT'] = 'admin'
    ENV['BOSH_CLIENT_SECRET'] = 'secret'
    allow_any_instance_of(BoshClient).to receive(:get).with('/deployments/cf-warden/vms?format=full').and_return(vms_response)
  end

  it 'returns the vms keyed by job_name' do
    vms = BoshVms.new('cf-warden')
    expect(vms.send(:[], 'example_service', 0, 'vm_type')).to eq 'resource_pool_1'
  end

  let(:vms_response) do
    JSON.parse(<<-JSON)
      [
        {
          "vm_cid": "3938cc70-8f5e-4318-ad05-24d991e0e66e",
          "disk_cid": null,
          "ips": ["10.0.1.3"],
          "dns": [],
          "agent_id": "d927e75b-2a2d-4015-b5cc-306a067e94e9",
          "job_name": "example_service",
          "index": 0,
          "job_state": "running",
          "state": "started",
          "resource_pool": "resource_pool_1",
          "vm_type": "resource_pool_1",
          "vitals": {
              "cpu": {
                  "sys": "0.3",
                  "user": "0.1",
                  "wait": "0.0"
              },
              "disk": {
                  "ephemeral": {
                      "inode_percent": "5",
                      "percent": "32"
                  },
                  "persistent": {
                      "inode_percent": "3",
                      "percent": "67"
                  },
                  "system": {
                      "inode_percent": "34",
                      "percent": "66"
                  }
              },
              "load": ["0.00", "0.01", "0.10"],
              "mem": {
                  "kb": "605008",
                  "percent": "7"
              },
              "swap": {
                  "kb": "75436",
                  "percent": "1"
              }
          },
          "processes": [{
              "name": "beacon",
              "state": "running",
              "uptime": {
                  "secs": 1212184
              },
              "mem": {
                  "kb": 776,
                  "percent": 0
              },
              "cpu": {
                  "total": 0
              }
          }, {
              "name": "baggageclaim",
              "state": "running",
              "uptime": {
                  "secs": 1212152
              },
              "mem": {
                  "kb": 8920,
                  "percent": 0.1
              },
              "cpu": {
                  "total": 0
              }
          }, {
              "name": "garden",
              "state": "running",
              "uptime": {
                  "secs": 1212153
              },
              "mem": {
                  "kb": 235004,
                  "percent": 2.8
              },
              "cpu": {
                  "total": 0.2
              }
          }],
          "az": null,
          "id": "abe6a4e9-cfca-490b-8515-2893f9e54d20",
          "bootstrap": false,
          "ignore": false
        }
      ]
    JSON
  end
end
