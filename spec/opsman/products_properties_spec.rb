require_relative '../spec_helper'
require 'inspec'
require 'opsman/support/opsman'

context 'product properties' do
  describe 'om_products_properties resource' do
    it 'returns product properties' do
      ENV['OM_TARGET'] = 'Set'
      allow_any_instance_of(Opsman).to receive(:get).with('/api/v0/deployed/products').and_return(products_response)
      allow_any_instance_of(Opsman).to receive(:get).with('/api/v0/staged/products/component-type1-guid/properties').and_return(properties_response)
      allow_any_instance_of(Opsman).to receive(:auth).and_return(false)
      products_properties = OmProductsProperties.new
      expect(products_properties.send(:[], 'component-type1', '.properties.example_selector', 'value')).to eq 'Pizza'
      expect(products_properties.send(:[], 'component-type1', '.properties.example_selector')).to include('value' => 'Pizza')
      expect(products_properties.send(:[], 'component-type1')).to include('.properties.example_selector' => include('value' => 'Pizza'))
    end
  end

  let(:properties_response) do
    JSON.parse(<<-JSON)
      {
        "properties": {
          ".properties.example_selector": {
            "type": "selector",
            "configurable": true,
            "credential": false,
            "value": "Pizza",
            "optional": false,
            "selected_option": "pizza_option"
          },
          ".properties.example_selector.pizza_option.pepperoni": {
            "type": "boolean",
            "configurable": true,
            "credential": false,
            "value": false,
            "optional": false
          },
          ".properties.example_selector.pizza_option.pineapple": {
            "type": "boolean",
            "configurable": true,
            "credential": false,
            "value": false,
            "optional": false
          },
          ".properties.example_selector.pizza_option.other_toppings": {
            "type": "string",
            "configurable": true,
            "credential": false,
            "value": null,
            "optional": true
          },
          ".web_server.static_ips": {
            "type": "ip_ranges",
            "configurable": true,
            "credential": false,
            "value": null,
            "optional": true
          }
        }
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
end
