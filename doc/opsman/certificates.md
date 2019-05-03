# om_certificates

view [opsman](readme.md) resources list.

## Overview

om_certificates is located in [/libraries/opsman/certificates.rb](/libraries/opsman/certificates.rb)

Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#getting-information-about-certificates-from-products


## Attributes/Methods


* `expires` boolean value if certificates will expire with selected criteria


## Example

```ruby
describe om_certificates(1, 'm') do
  its(%w[active_root_ca issuer]) { should eq 'Pivotal' }
  its('expires') { should be_empty }
end

```
