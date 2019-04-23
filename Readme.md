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

* `om_info` Opsman version
* `om_deployed_product` verify tiles are deployed and version
* `om_product_properties`verify tile properties
* `om_resource_job` verify resources for a job
* `om_director_properties` verify director properties
* `om_assigned_stemcells` verify version(s) of assigned stemcells
* `om_installations` verify opsman apply changes
* `om_certificates` verify opsman certificates
* `om_vm_extensions` verify vm extensions


#### Examples

Check the [examples](test/examples/om/controls)

### Running in Concourse

Add the following task to your pipeline and map the location of your tests to the "tests" input of the task.

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
```

### API caching

If you have many tests API calls might be slow. You can enable caching to increase test speed.
* `INSPEC_CACHE_TIME` defaults to `0` seconds
* `INSPEC_CACHE_DIR` defaults to `~/.inspec_cache`
