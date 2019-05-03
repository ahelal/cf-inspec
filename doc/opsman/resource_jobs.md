# om_resource_jobs

view [opsman](readme.md) resources list.

## Overview

om_resource_jobs is located in [/libraries/opsman/resource_jobs.rb](/libraries/opsman/resource_jobs.rb)
Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#retrieving-resource-configuration-for-a-product


## Attributes/Methods


* `element 0` the tile name i.e. cf


* `element 1` the jobs name i.e. diego_cell


## Example

```ruby
describe om_resource_jobs do
  its(%w[cf diego_cell instances]) { should eq 10 }
  its(%w[cf diego_cell additional_vm_extensions]) { should eq %w[vm_ext_configure_load_balancer vm_ext_setting_additional_security_groups] }
  its(%w[cf diego_cell instance_type id]) { should eq 'm3.medium' }
end

```
