[![Build Status](https://travis-ci.org/ahelal/cf-inspec.svg?branch=master)](https://travis-ci.org/ahelal/cf-inspec)

# inSpec Cloudfoundry resources

This InSpec resource pack that provides the required resources to write tests for cloudfoundry.

## Prerequisites

You need [inSpec](https://www.inspec.io/downloads/) :)

## Usage
### Create a new profile

1. `$ inspec init profile my-profile`

```yaml
name: my-profile
title: test
version: 0.1.0
depends:
  - name: cf-inspec
    url: https://github.com/ahelal/cf-inspec/archive/master.tar.gz
```

2. Edit inspec.yml to reflect the depends
3. Define your tests in `your_profile/control`

### Configuration for Opsman resources

You need to export **required** opsman variables
* `OM_TARGET` with schema eg. `https://opsman.example.com`
* `OM_USERNAME`
* `OM_PASSWORD`

Optional variables
* `OM_SKIP_SSL_VALIDATION` defaults to `false`

### Available resources

List of [available resources](doc/opsman)

#### Examples

Check the [examples](test/examples/opsman/controls)

```ruby
describe om_certificates(1, 'm') do
  its('expires') { should be_empty }
end

describe om_deployed_products do
  its(['pivotal-mysql', 'version']) { should match(/2.4.4/) }
end

describe om_director_properties do
  its(%w[iaas_configuration encrypted]) { should eq true }
  its(%w[director_configuration ntp_servers_string]) { should eq 'us.pool.ntp.org, time.google.com' }
  its(%w[iaas_configuration tls_enabled]) { should eq true }
  its(%w[syslog_configuration enabled]) { should eq true }
end

describe om_resource_jobs do
  its(%w[cf diego_cell instances]) { should eq 10 }
  its(%w[cf diego_cell instance_type id]) { should eq 'm3.medium' }
end
```

### Running in Concourse

Add the following task to your pipeline and map the location of your tests to the `specs` input. if your test is located in a subdir you need to pass that too `SPECS_SUBDIR: PATH/../`

You should read the inspec EULA and if you agree flip the `EULA: true`

```yaml
---
resources:
- name: cf-inspec-tasks
  type: git
  source:
    uri: https://github.com/ahelal/cf-inspec.git
    branch: master

- name: source-code
  type: git
  source:
    uri: https://github.com/<ORG>/<CODE>
    branch: master

jobs:
- name: run-inspec
  plan:
  - get: cf-inspec-tasks
  - get: source-code
  - task: run-inspec
    file: cf-inspec-tasks/task/task.yml
    input_mapping:
      specs: source-code
    params:
      OM_TARGET: ((OM_TARGET))
      OM_USERNAME: ((OM_USERNAME))
      OM_PASSWORD: ((OM_PASSWORD))
      SPECS_SUBDIR: test/examples/om
      INSPEC_CACHE_TIME: 0
      EULA: true
```

### API caching

If you have many tests API calls might be slow. You can enable caching to increase test speed.
* `INSPEC_CACHE_TIME` defaults to `0` seconds
* `INSPEC_CACHE_DIR` defaults to `~/.inspec_cache`
