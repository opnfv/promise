.. _yang_schema:

ANNEX B: Promise YANG schema based on YangForge
===============================================

.. code::

  module opnfv-promise {
  namespace "urn:opnfv:promise";
  prefix promise;

  import complex-types { prefix ct; }
  import ietf-yang-types { prefix yang; }
  import ietf-inet-types { prefix inet; }
  import access-control-models { prefix acm; }
  import nfv-infrastructure { prefix nfvi; }
  import nfv-mano { prefix mano; }

  description
    "OPNFV Promise Resource Reservation/Allocation controller module";

  revision 2015-10-05 {
    description "Complete coverage of reservation related intents";
  }

  revision 2015-08-06 {
    description "Updated to incorporate YangForge framework";
  }

  revision 2015-04-16 {
    description "Initial revision.";
  }

  feature reservation-service {
    description "When enabled, provides resource reservation service";
  }

  feature multi-provider {
    description "When enabled, provides resource management across multiple providers";
  }

  typedef reference-identifier {
    description "defines valid formats for external reference id";
    type union {
      type yang:uuid;
      type inet:uri;
      type uint32;
    }
  }

  grouping resource-utilization {
    container capacity {
      container total     { description 'Conceptual container that should be extended'; }
      container reserved  { description 'Conceptual container that should be extended';
                            config false; }
      container usage     { description 'Conceptual container that should be extended';
                            config false; }
      container available { description 'Conceptual container that should be extended';
                            config false; }
    }
  }

  grouping temporal-resource-collection {
    description
      "Information model capturing resource-collection with start/end time window";

    leaf start { type yang:date-and-time; }
    leaf end   { type yang:date-and-time; }

    uses nfvi:resource-collection;
  }

  grouping resource-usage-request {
    description
      "Information model capturing available parameters to make a resource
       usage request.";
    reference "OPNFV-PROMISE, Section 3.4.1";

    uses temporal-resource-collection {
      refine elements {
        description
          "Reference to a list of 'pre-existing' resource elements that are
         required for fulfillment of the resource-usage-request.

         It can contain any instance derived from ResourceElement,
         such as ServerInstances or even other
         ResourceReservations. If the resource-usage-request is
         accepted, the ResourceElement(s) listed here will be placed
         into 'protected' mode as to prevent accidental removal.

         If any of these resource elements become 'unavailable' due to
         environmental or administrative activity, a notification will
         be issued informing of the issue.";
      }
    }

    leaf zone {
      description "Optional identifier to an Availability Zone";
      type instance-identifier { ct:instance-type nfvi:AvailabilityZone; }
    }
  }

  grouping query-start-end-window {
    container window {
      description "Matches entries that are within the specified start/end time window";
      leaf start { type yang:date-and-time; }
      leaf end   { type yang:date-and-time; }
      leaf scope {
        type enumeration {
          enum "exclusive" {
            description "Matches entries that start AND end within the window";
          }
          enum "inclusive" {
            description "Matches entries that start OR end within the window";
          }
        }
        default "inclusive";
      }
    }
  }

  grouping query-resource-collection {
    uses query-start-end-window {
      description "Match for ResourceCollection(s) that are within the specified
                   start/end time window";
    }
    leaf-list without {
      description "Excludes specified collection identifiers from the result";
      type instance-identifier { ct:instance-type ResourceCollection; }
    }
    leaf show-utilization { type boolean; default true; }
    container elements {
      leaf-list some {
        description "Query for ResourceCollection(s) that contain some or more of
                     these element(s)";
        type instance-identifier { ct:instance-type nfvi:ResourceElement; }
      }
      leaf-list every {
        description "Query for ResourceCollection(s) that contain all of
                     these element(s)";
        type instance-identifier { ct:instance-type nfvi:ResourceElement; }
      }
    }
  }

  grouping common-intent-output {
    leaf result {
      type enumeration {
        enum "ok";
        enum "conflict";
        enum "error";
      }
    }
    leaf message { type string; }
  }

  grouping utilization-output {
    list utilization {
      key 'timestamp';
      leaf timestamp { type yang:date-and-time; }
      leaf count { type int16; }
      container capacity { uses nfvi:resource-capacity; }
    }
  }

  ct:complex-type ResourceCollection {
    ct:extends nfvi:ResourceContainer;
    ct:abstract true;

    description
      "Describes an abstract ResourceCollection data model, which represents
       a grouping of capacity and elements available during a given
       window in time which must be extended by other resource
       collection related models";

    leaf start { type yang:date-and-time; }
    leaf end   { type yang:date-and-time; }

    leaf active {
      config false;
      description
        "Provides current state of this record whether it is enabled and within
         specified start/end time";
      type boolean;
    }
  }

  ct:complex-type ResourcePool {
    ct:extends ResourceCollection;

    description
      "Describes an instance of an active ResourcePool record, which
       represents total available capacity and elements from a given
       source.";

    leaf source {
      type instance-identifier {
        ct:instance-type nfvi:ResourceContainer;
        require-instance true;
      }
      mandatory true;
    }

    refine elements {
      // following 'must' statement applies to each element
      // NOTE: just a non-working example for now...
      must "boolean(/source/elements/*[@id=id])" {
        error-message "One or more of the ResourceElement(s) does not exist in
                       the provider to be reserved";
      }
    }
  }

  ct:complex-type ResourceReservation {
    ct:extends ResourceCollection;

    description
      "Describes an instance of an accepted resource reservation request,
       created usually as a result of 'create-reservation' request.

       A ResourceReservation is a derived instance of a generic
       ResourceCollection which has additional parameters to map the
       pool(s) that were referenced to accept this reservation as well
       as to track allocations made referencing this reservation.

       Contains the capacities of various resource attributes being
       reserved along with any resource elements that are needed to be
       available at the time of allocation(s).";

    reference "OPNFV-PROMISE, Section 3.4.1";

    leaf created-on  { type yang:date-and-time; config false; }
    leaf modified-on { type yang:date-and-time; config false; }

    leaf-list pools {
      config false;
      description
        "Provides list of one or more pools that were referenced for providing
         the requested resources for this reservation.  This is an
         important parameter for informing how/where allocation
         requests can be issued using this reservation since it is
         likely that the total reserved resource capacity/elements are
         made availble from multiple sources.";
      type instance-identifier {
        ct:instance-type ResourcePool;
        require-instance true;
      }
    }

    container remaining {
      config false;
      description
        "Provides visibility into total remaining capacity for this
         reservation based on allocations that took effect utilizing
         this reservation ID as a reference.";

      uses nfvi:resource-capacity;
    }

    leaf-list allocations {
      config false;
      description
        "Reference to a collection of consumed allocations referencing
         this reservation.";
      type instance-identifier {
        ct:instance-type ResourceAllocation;
        require-instance true;
      }
    }
  }

  ct:complex-type ResourceAllocation {
    ct:extends ResourceCollection;

    description
      "A ResourceAllocation record denotes consumption of resources from a
       referenced ResourcePool.

       It does not reflect an accepted request but is created to
       represent the actual state about the ResourcePool. It is
       created once the allocation(s) have successfully taken effect
       on the 'source' of the ResourcePool.

       The 'priority' state indicates the classification for dealing
       with resource starvation scenarios. Lower priority allocations
       will be forcefully terminated to allow for higher priority
       allocations to be fulfilled.

       Allocations without reference to an existing reservation will
       receive the lowest priority.";

    reference "OPNFV-PROMISE, Section 3.4.3";

    leaf reservation {
      description "Reference to an existing reservation identifier (optional)";

      type instance-identifier {
        ct:instance-type ResourceReservation;
        require-instance true;
      }
    }

    leaf pool {
      description "Reference to an existing resource pool from which allocation is drawn";

      type instance-identifier {
        ct:instance-type ResourcePool;
        require-instance true;
      }
    }

    container instance-ref {
      config false;
      description
        "Reference to actual instance identifier of the provider/server
        for this allocation";
      leaf provider {
        type instance-identifier { ct:instance-type ResourceProvider; }
      }
      leaf server { type yang:uuid; }
    }

    leaf priority {
      config false;
      description
        "Reflects current priority level of the allocation according to
         classification rules";
      type enumeration {
        enum "high"   { value 1; }
        enum "normal" { value 2; }
        enum "low"    { value 3; }
      }
      default "normal";
    }
  }

  ct:complex-type ResourceProvider {
    ct:extends nfvi:ResourceContainer;

    key "name";
    leaf token { type string; mandatory true; }

    container services { // read-only
      config false;
      container compute {
        leaf endpoint { type inet:uri; }
        ct:instance-list flavors { ct:instance-type nfvi:ComputeFlavor; }
      }
    }

    leaf-list pools {
      config false;
      description
        "Provides list of one or more pools that are referencing this provider.";

      type instance-identifier {
        ct:instance-type ResourcePool;
        require-instance true;
      }
    }
  }

  // MAIN CONTAINER
  container promise {

    uses resource-utilization {
      description "Describes current state info about capacity utilization info";

      augment "capacity/total"     { uses nfvi:resource-capacity; }
      augment "capacity/reserved"  { uses nfvi:resource-capacity; }
      augment "capacity/usage"     { uses nfvi:resource-capacity; }
      augment "capacity/available" { uses nfvi:resource-capacity; }
    }

    ct:instance-list providers {
      if-feature multi-provider;
      description "Aggregate collection of all registered ResourceProvider instances
                   for Promise resource management service";
      ct:instance-type ResourceProvider;
    }

    ct:instance-list pools {
      if-feature reservation-service;
      description "Aggregate collection of all ResourcePool instances";
      ct:instance-type ResourcePool;
    }

    ct:instance-list reservations {
      if-feature reservation-service;
      description "Aggregate collection of all ResourceReservation instances";
      ct:instance-type ResourceReservation;
    }

    ct:instance-list allocations {
      description "Aggregate collection of all ResourceAllocation instances";
      ct:instance-type ResourceAllocation;
    }

    container policy {
      container reservation {
        leaf max-future-start-range {
          description
            "Enforce reservation request 'start' time is within allowed range from now";
          type uint16 { range 0..365; }
          units "days";
        }
        leaf max-future-end-range {
          description
            "Enforce reservation request 'end' time is within allowed range from now";
          type uint16 { range 0..365; }
          units "days";
        }
        leaf max-duration {
          description
            "Enforce reservation duration (end-start) does not exceed specified threshold";
          type uint16;
          units "hours";
          default 8760; // for now cap it at max one year as default
        }
        leaf expiry {
          description
            "Duration in minutes from start when unallocated reserved resources
             will be released back into the pool";
          type uint32;
          units "minutes";
        }
      }
    }
  }

  //-------------------
  // INTENT INTERFACE
  //-------------------

  // RESERVATION INTENTS
  rpc create-reservation {
    if-feature reservation-service;
    description "Make a request to the reservation system to reserve resources";
    input {
      uses resource-usage-request;
    }
    output {
      uses common-intent-output;
      leaf reservation-id {
        type instance-identifier { ct:instance-type ResourceReservation; }
      }
    }
  }

  rpc update-reservation {
    description "Update reservation details for an existing reservation";
    input {
      leaf reservation-id {
        type instance-identifier {
          ct:instance-type ResourceReservation;
          require-instance true;
        }
        mandatory true;
      }
      uses resource-usage-request;
    }
    output {
      uses common-intent-output;
    }
  }

  rpc cancel-reservation {
    description "Cancel the reservation and be a good steward";
    input {
      leaf reservation-id {
        type instance-identifier { ct:instance-type ResourceReservation; }
        mandatory true;
      }
    }
    output {
      uses common-intent-output;
    }
  }

  rpc query-reservation {
    if-feature reservation-service;
    description "Query the reservation system to return matching reservation(s)";
    input {
      leaf zone { type instance-identifier { ct:instance-type nfvi:AvailabilityZone; } }
      uses query-resource-collection;
    }
    output {
      leaf-list reservations { type instance-identifier
                               { ct:instance-type ResourceReservation; } }
      uses utilization-output;
    }
  }

  // CAPACITY INTENTS
  rpc increase-capacity {
    description "Increase total capacity for the reservation system
                 between a window in time";
    input {
      uses temporal-resource-collection;
      leaf source {
        type instance-identifier {
          ct:instance-type nfvi:ResourceContainer;
        }
      }
    }
    output {
      uses common-intent-output;
      leaf pool-id {
        type instance-identifier { ct:instance-type ResourcePool; }
      }
    }
  }

  rpc decrease-capacity {
    description "Decrease total capacity for the reservation system
                 between a window in time";
    input {
      uses temporal-resource-collection;
      leaf source {
        type instance-identifier {
          ct:instance-type nfvi:ResourceContainer;
        }
      }
    }
    output {
      uses common-intent-output;
      leaf pool-id {
        type instance-identifier { ct:instance-type ResourcePool; }
      }
    }
  }

  rpc query-capacity {
    description "Check available capacity information about a specified
                 resource collection";
    input {
      leaf capacity {
        type enumeration {
          enum 'total';
          enum 'reserved';
          enum 'usage';
          enum 'available';
        }
        default 'available';
      }
      leaf zone { type instance-identifier { ct:instance-type nfvi:AvailabilityZone; } }
      uses query-resource-collection;
      // TBD: additional parameters for query-capacity
    }
    output {
      leaf-list collections { type instance-identifier
                              { ct:instance-type ResourceCollection; } }
      uses utilization-output;
    }
  }

  // ALLOCATION INTENTS (should go into VIM module in the future)
  rpc create-instance {
    description "Create an instance of specified resource(s) utilizing capacity
                 from the pool";
    input {
      leaf provider-id {
        if-feature multi-provider;
        type instance-identifier { ct:instance-type ResourceProvider;
                                   require-instance true; }
      }
      leaf name   { type string; mandatory true; }
      leaf image  {
        type reference-identifier;
        mandatory true;
      }
      leaf flavor {
        type reference-identifier;
        mandatory true;
      }
      leaf-list networks {
        type reference-identifier;
        description "optional, will assign default network if not provided";
      }

      // TODO: consider supporting a template-id (such as HEAT) for more complex instantiation

      leaf reservation-id {
        type instance-identifier { ct:instance-type ResourceReservation;
                                   require-instance true; }
      }
    }
    output {
      uses common-intent-output;
      leaf instance-id {
        type instance-identifier { ct:instance-type ResourceAllocation; }
      }
    }
  }

  rpc destroy-instance {
    description "Destroy an instance of resource utilization and release it
                 back to the pool";
    input {
      leaf instance-id {
        type instance-identifier { ct:instance-type ResourceAllocation;
                                   require-instance true; }
      }
    }
    output {
      uses common-intent-output;
    }
  }

  // PROVIDER INTENTS (should go into VIM module in the future)
  rpc add-provider {
    description "Register a new resource provider into reservation system";
    input {
      leaf provider-type {
        description "Select a specific resource provider type";
        mandatory true;
        type enumeration {
          enum openstack;
          enum hp;
          enum rackspace;
          enum amazon {
            status planned;
          }
          enum joyent {
            status planned;
          }
          enum azure {
            status planned;
          }
        }
        default openstack;
      }
      uses mano:provider-credentials {
        refine endpoint {
          default "http://localhost:5000/v2.0/tokens";
        }
      }
      container tenant {
        leaf id { type string; }
        leaf name { type string; }
      }
    }
    output {
      uses common-intent-output;
      leaf provider-id {
        type instance-identifier { ct:instance-type ResourceProvider; }
      }
    }
  }

  // TODO...
  notification reservation-event;
  notification capacity-event;
  notification allocation-event;
  }
