# om_products_properties

view [opsman](readme.md) resources list.

## Overview

om_products_properties is located in [/libraries/opsman/products_properties.rb](/libraries/opsman/products_properties.rb)

Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#retrieving-resource-configuration-for-a-product


## Attributes/Methods


* `element 0` the tile name i.e. cf


* `element n` nest property


## Example

```ruby
describe om_products_properties do
  its(['pivotal-mysql', '.properties.plan3_selector.active.name', 'value']) { should eq 'db-large' }
end

```
