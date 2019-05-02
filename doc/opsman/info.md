# om_info

view [opsman](readme.md) resources list.

## Overview

om_info is located in [/libraries/opsman/info.rb](/libraries/opsman/info.rb)
Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#getting-information-about-ops-manager


## Attributes/Methods


* `version` contains the opsman version.


* `raw_attribute` contains the raw api response.


## Example

```ruby
control 'opsman should be reachable and using desired version' do
    describe bosh_info do
      its('version') { should match(/2.3/) }
    end
    describe bosh_info do
      its('version') { should eq 'v2.3.0-build.79' }
    end
    describe bosh_info do
      its('raw_content') { should include('info' => { 'version => match(/2.3/) }) }
    end
  end

```
