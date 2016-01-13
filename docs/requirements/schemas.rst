.. _yang_schema:

ANNEX B: Promise YANG schema based on YangForge
===============================================

.. code::

  module opnfv-promise {
  namespace "urn:opnfv:promise";
  prefix promise;

  import complex-types { prefix ct; }
  import iana-crypt-hash { prefix ianach; }
  import ietf-inet-types { prefix inet; }
  import ietf-yang-types { prefix yang; }
  import opnfv-promise-vim { prefix vim; }

  feature multi-provider {
    description "";
  }

  description
    "OPNFV Promise Resource Reservation/Allocation controller module";

  revision 2015-04-16 {
    description "Initial revision.";
  }

  revision 2015-08-06 {
    description "Updated to incorporate YangForge framework";
  }

  grouping resource-capacity {
    container capacity {
      container quota { description 'Conceptual container that should be extended'; }
      container usage { description 'Conceptual container that should be extended';
                        config false; }
      container reserved { description 'Conceptual container that should be extended';
                           config false; }
      container available { description 'Conceptual container that should be extended';
                            config false; }
    }
  }

  grouping compute-capacity {
    leaf cores { type number; }
    leaf ram { type number; }
    leaf instances { type number; }
  }

  grouping networking-capacity {
    leaf network { type number; }
    leaf port { type number; }
    leaf router { type number; }
    leaf subnet { type number; }
    leaf address { type number; }
  }

  ct:complex-type ResourceReservation {
    ct:extends vim:ResourceElement;

    description
      "Contains the capacities of various resource services being reserved
       along with any resource elements needed to be available at
       the time of allocation(s).";

    reference "OPNFV-PROMISE, Section 3.4.1";

    leaf start { type yang:date-and-time; }
    leaf end   { type yang:date-and-time; }
    leaf expiry {
      description "Duration in seconds from start when unallocated reserved resources
                   will be released back into the pool";
      type number; units "seconds";
    }
    leaf zone { type instance-identifier { ct:instance-type vim:AvailabilityZone; } }
    container capacity {
      uses vim:compute-capacity;
      uses vim:networking-capcity;
      uses vim:storage-capacity;
    }
    leaf-list resources {
      description
        "Reference to a collection of existing resource elements required by
         this reservation. It can contain any instance derived from
         ResourceElement, such as ServerInstances or even other
         ResourceReservations. If the ResourceReservation request is
         accepted, the ResourceElement(s) listed here will be placed
         into 'protected' mode as to prevent accidental delete.";
      type instance-identifier {
        ct:instance-type vim:ResourceElement;
      }
      // following 'must' statement applies to each element
      must "boolean(/provider/elements/*[@id=id])" {
        error-message "One or more of the ResourceElement(s) does not exist in
                       the provider to be reserved";
      }
    }

    leaf provider {
      if-feature multi-provider;
      config false;

      description
        "Reference to a specified existing provider from which this reservation
         will be drawn if used in the context of multi-provider
         environment.";
      type instance-identifier {
        ct:instance-type vim:ResourceProvider;
        require-instance true;
      }
    }

    container remaining {
      config false;
      description
        "Provides visibility into total remaining capacity for this
         reservation based on allocations that took effect utilizing
         this reservation ID as a reference.";

      uses vim:compute-capacity;
      uses vim:networking-capcity;
      uses vim:storage-capacity;
    }

    leaf-list allocations {
      config false;
      description
        "Reference to a collection of consumed allocations referencing
         this reservation.";
      type instance-identifier {
        ct:instance-type ResourceAllocation;
      }
    }
  }

  ct:complex-type ResourceAllocation {
    ct:extends vim:ResourceElement;

    description
       "Contains a list of resources to be allocated with optional reference
       to an existing reservation.

       If reservation is specified but this request is received prior
       to reservation start timestamp, then it will be rejected unless
       'allocate-on-start' is set to true.  'allocate-on-start' allows
       the allocation to be auto-initiated and scheduled to run in the
       future.

       The 'priority' state indicates the classification for dealing
       with resource starvation scenarios. Lower priority allocations
       will be forcefully terminated to allow for higher priority
       allocations to be fulfilled.

       Allocations without reference to an existing reservation will
       receive the lowest priority.";

    reference "OPNFV-PROMISE, Section 3.4.3";

    leaf reservation {
      description "Reference to an existing reservation identifier";

      type instance-identifier {
        ct:instance-type ResourceReservation;
        require-instance true;
      }
    }

    leaf allocate-on-start {
      description
       "If 'allocate-on-start' is set to true, the 'planned' allocations will
       take effect automatically at the reservation 'start' date/time.";
      type boolean; default false;
    }

    ct:instance-list resources {
      description "Contains list of new ResourceElements that will be allocated";
      ct:instance-type vim:ResourceElement;
    }

    leaf priority {
      description
        "Reflects current priority level of the allocation according to classification rules";
      type number;
      config false;
    }
  }

  // MAIN CONTAINER
  container promise {
    ct:instance-list providers {
      description "Aggregate collection of all registered ResourceProvider instances";
      ct:instance-type vim:ResourceProvider;
      config false;

     // augment compute container with capacity elements
     augment "compute" {
       uses resource-capacity {
         augment "capacity/quota" { uses compute-capacity; }
         augment "capacity/usage" { uses compute-capacity; }
         augment "capacity/reserved" { uses compute-capacity; }
         augment "capacity/available" { uses compute-capacity; }
       }
     }

     // augment networking container with capacity elements
     augment "networking" {
       uses resource-capacity {
         if-feature has-networking-capacity;
         augment "capacity/quota" { uses networking-capacity; }
         augment "capacity/usage" { uses networking-capacity; }
         augment "capacity/reserved" { uses networking-capacity; }
         augment "capacity/available" { uses networking-capacity; }
       }
     }

     // track references to reservations for this resource provider
     leaf-list reservations {
       type instance-identifier {
         ct:instance-type ResourceReservation;
       }
     }
    }

    ct:instance-list reservations {
      description "Aggregate collection of all registered ResourceReservation instances";
      ct:instance-type ResourceReservation;
    }

    ct:instance-list allocations {
      description "Aggregate collection of all active ResourceAllocation instances";
      ct:instance-type ResourceAllocation;
    }
  }

  rpc add-provider {
    description "This operation allows you to register a new ResourceProvider
                 into promise management service";
    input {
      leaf provider {
        description "Select a specific resource provider";
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
      }
      leaf username {
        type string;
        mandatory true;
      }
      leaf password {
        type ianach:crypt-hash;
        mandatory true;
      }
      leaf endpoint {
        type inet:uri;
        description "The target URL endpoint for the resource provider";
        mandatory true;
      }
      leaf region {
        type string;
        description "Optional specified regsion for the provider";
      }
    }
    output {
      leaf id {
        description "Unique identifier for the newly added provider found in /promise/providers";
        type instance-identifier {
          ct:instance-type ResourceProvider;
        }
      }
      leaf result {
        type enumeration {
          enum success;
          enum error;
        }
      }
    }
  }
  rpc remove-provider;
  rpc list-providers;

  rpc check-capacity;

  rpc list-reservations;
  rpc create-reservation;
  rpc update-reservation;
  rpc cancel-reservation;

  rpc list-allocations;
  rpc create-allocation;

  notification reservation-event;
  notification capacity-event;
  notification allocation-event;
  }
