# om_vm_extensions

view [opsman](readme.md) resources list.

## Overview

om_vm_extensions is located in [/libraries/opsman/vm_extensions.rb](/libraries/opsman/vm_extensions.rb)

Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#deployed-vm-extensions


## Attributes/Methods


* `extensions` get all vm extensions without filters


* `extension` return a specific extension (must be supplied as an argument)


## Example

```ruby
control 'OM vm extensions all loadbalancer' do
  describe om_vm_extensions do
    its('extensions') { should_not be_empty }
  end
end
control 'OM vm extensions tags A' do
  cp = { 'cloud_properties' => { 'tags' => %w[tag1 tag2 tag3] }, 'name' => 'A' }
  describe om_vm_extensions('EXT_A') do
    its('extension') { should eq cp }
  end
end

```
