# Resource Management for Virtual Infrastructure

**Promise** is a resource reservation and management project to identify NFV related requirements and realize resource reservation for future usage by capacity management of resource pools regarding compute, network and storage.

The following are the key features provided by this module:

* Resource Capacity Management
* Resource Reservation
* Resource Allocation

This module also contains a collection of [YANG data models](schema/) as defined under the direction of [OPNFV Promise](http://wiki.opnfv.org/promise) project.

## Installation

`opnfv-promise` is built with [YangForge](http://github.com/opnfv/yangforge) data modeling
framework. You will need to first install `yangforge` and use the
provided `yfc` command line utility to run this module.

```bash
$ npm install -g yangforge
```

There are also alternative installer plugins for [Fuel](http://github.com/opnfv/fuel-plugin-promise) and [Juju](http://github.com/opnfv/juju-plugin-promise).

## Usage
```bash
$ yfc run promise.yaml
```

The `yfc run` command will load the primary application
package from this repository along with any other dependency
files/assets referenced within the YAML manifest and instantiate the
opnfv-promise module and run REST/JSON interface by default listening
on port 5000.

You can also checkout this GIT repository or simply download the files
into your local system and run the application.

## Testing

```bash
$ npm install
$ npm test
```

TBD

## Primary YANG Data Models

name | description | status
--- | --- | ---
[opnfv-promise](schema/opnfv-promise.yang) | provide resource reservation and capacity management | 95% complete
[nfv-infrastructure](schema/nfv-infrastructure.yang) | common NFV Infrastructure resource models | 80% complete
[nfv-mano](schema/nfv-mano.yang) | common NFV MANO resource models including VIM | 20% complete
[openstack](schema/openstack.yang) | openstack specific VIM extensions | 50% complete

## Promise Information Models

### ResourceReservation

The data model describing the required parameters regarding a resource
reservation. The schema definition expressed in Yang can be found
[here](schema/opnfv-promise.yang).

#### Key Elements

Name | Type | Description
---  | ---  | ---
start | ys:date-and-time | Timestamp of when the consumption of reserved resources can begin
end   | ys:date-and-time | Timestamp of when the consumption of reserved resource must end
expiry | number | Duration expressed in seconds since `start` when resource not yet allocated shall be released back to the available zone
zone | nfvi:AvailabilityZone | Reference to a zone where the resources will be reserved
capacity | object | Quantity of resources to be reserved per resource types
attributes | list | References to resource attributes needed for reservation
resources | list (nfvi:ResourceElement) | Reference to a collection of existing resource elements required

#### State Elements (read-only)

State Elements are available as part of lookup response about the data model.

Name | Type | Description
---  | ---  | ---
provider | nfvi:ResourceProvider | Reference to a specific provider when reservation service supports multiple providers
remaining | object | Quantity of resources remaining for consumption based on consumed allocations
allocations | list (nfvi:ResourceAllocation) | Reference to a collection of consumed allocations referencing this reservation

#### Notification Elements

Name | Type | Description
---  | ---  | ---
reservation-event | Event | Subscribers will be notified if the reservation encounters an error or other events

#### Inherited Elements

##### Extended from [nfvi:ResourceElement](schema/nfv-infrastructure.yang)

Name | Type | Description
---  | ---  | ---
id | yang:uuid | A GUID identifier for the data model (usually auto-generated, but can also be specified)
name | string | Name of the data model
enabled | boolean | Enable/Disable the data model
protected | boolean | Prevent model from being destroyed when protected
owner | nfvi:AccessIdentity | An owner for the data model
visibility | enumeration | Visibility level of the given data model
tags | list (string) | List of string tags for query/filter
members | list (nfvi:AccessIdentity) | List of additional AccessIdentities that can operate on the data model

### Resource Allocation

The data model describing the required parameters regarding a resource
allocation.  The schema definition expressed in YANG can be found
[here](schema/opnfv-promise.yang).

#### Key Elements

Name | Type | Description
---  | ---  | ---
reservation | nfvi:ResourceReservation | Reference to an existing reservation identifier
allocate-on-start | boolean | Specify whether the allocation can take effect automatically upon reservation 'start'
resources | list (nfvi:ResourceElement) | Reference to a collection of new resource elements to be allocated

#### State Elements (read-only)

Name | Type | Description
---  | ---  | ---
priority | number | Read-only state information about the priority classification of the reservation

#### Inherited Elements

##### Extended from [nfvi:ResourceElement](schema/nfv-infrastructure.yang)

Name | Type | Description
---  | ---  | ---
id | yang:uuid | A GUID identifier for the data model (usually auto-generated, but can also be specified)
name | string | Name of the data model
enabled | boolean | Enable/Disable the data model
protected | boolean | Prevent model from being destroyed when protected
owner | nfvi:AccessIdentity | An owner for the data model
visibility | enumeration | Visibility level of the given data model
tags | list (string) | List of string tags for query/filter
members | list (nfvi:AccessIdentity) | List of additional AccessIdentities that can operate on the data model

## License
  [Apache-2.0](LICENSE)
