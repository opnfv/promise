Promise YANG Schemas based on StormForge
----------------------------------------

Promise Schema
^^^^^^^^^^^^^^

.. code::

  module opnfv-promise {
    namespace "urn:opnfv:vim:promise";
    prefix prom;

    import opnfv-promise-models { prefix opm; }
    import complex-types { prefix ct; }

    description
      "OPNFV Promise Resource Reservation/Allocation controller module";

    revision 2015-04-16 {
      description
        "Initial revision.";
    }

    // MAIN CONTAINER

    container promise {
      ct:instance-list reservations {
        description "Aggregate collection of all registered ResourceReservation instances";
        ct:instance-type opm:ResourceReservation;
      }
    }

    rpc list-reservations;
    rpc create-reservation;
    rpc cancel-reservation;

    notification reservation-event;
    notification capacity-event;
    notification allocation-event;
  }

OPNFV Promise YANG Schema
^^^^^^^^^^^^^^^^^^^^^^^^^

.. code::

  module opnfv-promise-models {
    prefix opm;

    import storm-common-models { prefix scm; }
    import complex-types { prefix ct; }

    feature resource-reservation;

    ct:complex-type ResourceReservation {
      ct:extends scm:ResourceElement;

      description
        "Contains the capacities of various resource services being reserved
         along with any resource elements needed to be available at
         the time of allocation(s).";

      reference "OPNFV-PROMISE, Section 3.4.1";

      leaf start { type ct:date-and-time; }
      leaf end   { type ct:date-and-time; }
      leaf expiry {
        description "Duration in seconds from start when unallocated reserved resources will be released back into the pool";
        type number; units "seconds";
      }
      leaf zone { type instance-identifier { ct:instance-type scm:AvailabilityZone; } }
      container capacity {
        uses scm:compute-capacity;
        uses scm:networking-capcity;
        uses scm:storage-capacity;
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
          ct:instance-type scm:ResourceElement;
        }
        // following 'must' statement applies to each element
        must "boolean(/provider/elements/*[@id=id])" {
          error-message "One or more of the ResourceElement(s) does not exist in the provider to be reserved";
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
          ct:instance-type scm:ResourceProvider;
          require-instance true;
        }
      }

      container remaining {
        config false;
        description
          "Provides visibility into total remaining capacity for this
           reservation based on allocations that took effect utilizing
           this reservation ID as a reference.";

        uses scm:compute-capacity;
        uses scm:networking-capcity;
        uses scm:storage-capacity;
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
      ct:extends scm:ResourceElement;

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
        ct:instance-type scm:ResourceElement;
      }

      leaf priority {
        description
          "Reflects current priority level of the allocation according to classification rules";
        type number;
        config false;
      }
    }
  }

.. -*
