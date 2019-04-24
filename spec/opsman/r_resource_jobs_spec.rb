require_relative '../spec_helper'
require 'inspec'
require 'opsman/opsman'

context 'resource_jobs' do
  describe 'opsman resource_jobs resource' do
    it 'returns resource information' do
      ENV['OM_TARGET'] = 'Set'
      allow_any_instance_of(Opsman).to receive(:get).with('/api/v0/deployed/products').and_return(products_response)
      allow_any_instance_of(Opsman).to receive(:get).with('/api/v0/staged/products/component-type1-guid/jobs').and_return(jobs_response)
      allow_any_instance_of(Opsman).to receive(:get).with('/api/v0/staged/products/component-type1-guid/jobs/web-server12345sdfk/resource_config').and_return(resource_response)
      allow_any_instance_of(Opsman).to receive(:auth).and_return(false)
      resource_jobs = OmResourceJobs.new
      expect(resource_jobs['component-type1', 'web-server', 'instances']).to eq 7
    end
  end

  let(:resource_response) do
    JSON.parse(<<-JSON)
      {
          "instance_type": {
              "id": "xlarge.disk"
          },
          "instances": 7,
          "internet_connected": false,
          "elb_names": [],
          "additional_vm_extensions": [
              "foo"
          ],
          "swap_as_percent_of_memory_size": "automatic"
      }
    JSON
  end

  let(:products_response) do
    JSON.parse(<<-JSON)
      [
        {
          "installation_name": "component-type1-installation-name",
          "guid": "component-type1-guid",
          "type": "component-type1",
          "product_version": "1.0",
          "stale": {
            "parent_products_deployed_more_recently": ["p-bosh-guid"]
          }
        }
      ]
    JSON
  end

  let(:jobs_response) do
    JSON.parse(<<-JSON)
      {
        "jobs": [
          {
            "guid": "web-server12345sdfk",
            "name": "web-server"
          },
          {
            "guid": "etcd12345sdfk",
            "name": "etcd"
          }
        ]
      }
    JSON
  end
end
