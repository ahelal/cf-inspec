# om_assigned_stemcells

view [opsman](readme.md) resources list.

## Overview

om_assigned_stemcells is located in [/libraries/opsman/stemcells.rb](/libraries/opsman/stemcells.rb)
Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#deployed-vm-extensions


## Attributes/Methods


* `extensions` get all vm extensions without filters


* `extension` return a specific extension (must be supplied as an argument)


## Example

```ruby
control 'Assigned PAS stemcell' do
  title 'should be pinned'
  describe om_assigned_stemcells('cf') do
    its('version') { should eq '97.74' }
  end
end
control 'All assigned stemcell' do
  title 'should be ubuntu xenial'
  describe om_assigned_stemcells do
    its('versions') { should all(include('97.')) }
  end
end

```
