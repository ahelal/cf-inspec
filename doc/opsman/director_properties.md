# om_director_properties

view [opsman](readme.md) resources list.

## Overview

om_director_properties is located in [/libraries/opsman/director_properties.rb](/libraries/opsman/director_properties.rb)

Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#staged-bosh-director


## Attributes/Methods


* `director_properties` get all bosh director properties.


## Example

```ruby
describe om_director_properties do
  its(%w[iaas_configuration encrypted]) { should eq true }
  its(%w[director_configuration ntp_servers_string]) { should eq 'us.pool.ntp.org, time.google.com' }
  its(%w[iaas_configuration tls_enabled]) { should eq true }
  its(%w[syslog_configuration enabled]) { should eq true }
end

```
