# inspec Opsman/bosh resource(s)

This InSpec resource pack that provides the required resources to write tests for Opsman & bosh.

## Prerequisites

You need [inspec](https://www.inspec.io/downloads/) :)

### Opsman variables

You need to export opsman
* `OM_TARGET` with schema eg. `https://opsman.example.com`
* `OM_USERNAME`
* `OM_PASSWORD`

## Usage
### Create a new profile

1. ```sh $ inspec init profile my-profile```

```yaml
name: my-profile
title: test
version: 0.1.0
depends:
  - name: inspec-bosh
    url: https://github.com/ahelal/inspec-bosh/archive/master.tar.gz
```

2. Edit inspec.yml to reflect the depends
3. Define your tests in `your_profile/control`


### Available resources

* `om_info` Opsman version
* `om_deployed_product` verify tiles are deployed and version
* `om_product_properties`verify tile properties
* `om_resource_job` verify resources for a job
* `om_director_properties` verify director properties
* `om_assigned_stemcells` verify version(s) of assigned stemcells

Check the [examples](blob/master/test/example/controls)

### Improvements

* Cache API calls as it slow
