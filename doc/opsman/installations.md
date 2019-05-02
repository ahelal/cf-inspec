# om_installations

view [opsman](readme.md) resources list.

## Overview

om_installations is located in [/libraries/opsman/installations.rb](/libraries/opsman/installations.rb)
Opsman reference:

* https://docs.pivotal.io/pivotalcf/2-4/opsman-api/#getting-a-list-of-recent-install-events


## Attributes/Methods


* `status_of_last_run` status of last run


* `status_of_last_completed_run` status of last completed run


* `duration_of_last_completed_run` duration in seconds of last completed run


* `last_run` raw format of last run


* `last_completed_run` raw format of completed last run


* `raw_attribute` contains the raw api response.


## Example

```ruby
describe om_installations do
  its('status_of_last_run') { should eq 'succeeded' }
  its('status_of_last_completed_run') { should eq 'succeeded' }
  its('duration_of_last_completed_run') { should be < 60 * 60 }
end

```
