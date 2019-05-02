# om_deployed_products

view [opsman](readme.md) resources list.

## Overview

om_deployed_products is located in [/libraries/opsman/deployed_products.rb](/libraries/opsman/deployed_products.rb)
Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#retrieving-resource-configuration-for-a-product


## Attributes/Methods


* `element 0` the tile name i.e. cf


* `element 1` version


## Example

```ruby
describe om_deployed_products do
  its(['pivotal-mysql', 'version']) { should match /2.4.4/ }
end

```
