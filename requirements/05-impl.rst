Detailed architecture and message flows
=======================================

Detailed northbound interface specification
-------------------------------------------

.. Note::
   This is Work in Progress

Virtualised Compute Resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ETSI NFV IFA Information Models
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Compute Flavor
______________

A compute flavor includes information about number of virtual CPUs, size of virtual memory,
size of virtual storage, and virtual network interfaces [NFVIFA005]_

.. uml::

   @startuml
   class ComputeFlavor {
     + flavorId [1]: Identifier
     + virtualCpu [1]: VirtualCpu
     + virtualMemory [1]: VirtualMemory
     + virtualStorage [0..N]: VirtualStorage
     + virtualNetworkInterface [0..N]: VirtualNetworkInterface
     + accelerationCapabilities [0..N]:
   }

   class VirtualCpu {
     + cpuArchitecture [0..1]:
     + numVirtualCpu [1|: Number
     + virtualCpuClock [0..1]: Number
     + virtualCpuOversubscriptionPolicy [0..1]:
     + virtualCpuPinning [0..1]: VirtualCpuPinning
   }

   class VirtualCpuPinning {
     + cpuPinningPolicy [0..1]:
     + cpuPinningMap [0..1]:
   }

   class VirtualMemory {
     + virtualMemSize [1]: Number
     + virtualMemOversubscriptionPolicy [0..1]:
     + numaEnabled [0..1]: Boolean
   }

   class VirtualStorage {
     + typeofStorage [1|:
     + sizeOfStorage [1]: Number
   }

   class VirtualNetworkInterface {
     + networkId [0..1]: Identifier
     + networkPortId [0..1]: Identifier
     + ipAddress [0..N]:
     + typeVirtualNic [1]:
     + typeConfiguration [0..N]:
     + macAddress [0..1]:
     + bandwidth [0..1]: Number
     + nicAccelerationCapabilities [0..N]:
     + metadata [0..N]: KeyValue
   }

   ComputeFlavor "1" *- "1" VirtualCpu : ""
   ComputeFlavor "1" *- "1" VirtualMemory : ""
   ComputeFlavor "1" *- "0..N" VirtualStorage : ""
   ComputeFlavor "1" *- "0..N" VirtualNetworkInterface: ""
   VirtualCpu "1" *- "0..1" VirtualCpuPinning : ""
   @enduml

.. -*

Virtualised Resources Capacity Management
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Subscribe Compute Capacity Change Event
_______________________________________

Subscription from Consumer to VIM to be notified about compute capacity changes

.. http:post:: /capacity/compute/subscribe
   :noindex:

   **Example request**:

   .. sourcecode:: http

       POST /capacity/compute/subscribe HTTP/1.1
       Accept: application/json

       {
          "zoneId": "12345",
          "resourceDescriptor": [
              {
                 "computeresourceTypeId": "vcinstances"
              }
          ],
          "threshold": [
              {
                 "capacity_info": "available",
                 "condition": "lt",
                 "value": 5
              }
          ]
      }

   **Example response**:

   .. sourcecode:: http

       HTTP/1.1 201 CREATED
       Content-Type: application/json

       {
          "created": "2015-09-21T00:00:00Z",
          "capacityChangeSubscriptionId": "abcdef-ghijkl-123456789"
       }

   :statuscode 400: resourceDescriptor is missing

Query Compute Capacity
______________________

Request to find out about available, reserved, total and allocated compute capacity.

.. http:get:: /capacity/compute/query
   :noindex:

   **Example request**:

   .. sourcecode:: http

      GET /capacity/compute/query HTTP/1.1
      Accept: application/json

      {
        "zoneId": "12345",
        "resourceDescriptor":  {
             "computeresourceTypeId": "vcinstances"
        },
        "timePeriod":  {
             "startTime": "2015-09-21T00:00:00Z",
             "stopTime": "2015-09-21T00:05:30Z"
        }
      }

   **Example response**:

   .. sourcecode:: http

       HTTP/1.1 200 OK
       Content-Type: application/json

       {
          "zoneId": "12345",
          "lastUpdate": "2015-09-21T00:03:20Z",
          "capacityInformation": {
             "available": 4,
             "reserved": 17,
             "total": 50,
             "allocated": 29
          }
       }

   :query limit: Default is 10.
   :statuscode 404: resource zone unknown

Notify Compute Capacity Change Event
____________________________________

Notification about compute capacity changes

.. http:post:: /capacity/compute/notification
   :noindex:

   **Example notification**:

   .. sourcecode:: http

      Content-Type: application/json

      {
           "zoneId": "12345",
           "notificationId": "zyxwvu-tsrqpo-987654321",
           "capacityChangeTime": "2015-09-21T00:03:20Z",
           "resourceDescriptor": {
              "computeresourceTypeId": "vcinstances"
           },
           "capacityInformation": {
              "available": 4,
              "reserved": 17,
              "total": 50,
              "allocated": 29
           }
      }

Compute Resource Reservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create Compute Resource Reservation
___________________________________

Request the reservation of compute resource capacity and/or virtualized containers

.. http:post:: /reservation/compute/create
   :noindex:

   **Example request**:

   .. sourcecode:: http

       POST /reservation/compute/create HTTP/1.1
       Accept: application/json

       {
           "startTime": "2015-09-21T01:00:00Z",
           "computePoolReservation": {
               "numCpuCores": 20,
               "numVcInstances": 5,
               "virtualMemSize": 10
           }
       }

   **Example response**:

   .. sourcecode:: http

       HTTP/1.1 201 CREATED
       Content-Type: application/json

       {
          "reservationData": {
             "startTime": "2015-09-21T01:00:00Z",
             "reservationStatus": "initialized",
             "reservationId": "xxxx-yyyy-zzzz",
             "computePoolReserved": {
                 "numCpuCores": 20,
                 "numVcInstance": 5,
                 "virtualMemSize": 10,
                 "zoneId": "23456"
             }
          }
       }


Detailed Message Flows
----------------------

Resource Capacity Management
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: images/figure5.png
   :name: figure5
   :width: 90%

   Capacity Management Scenario

:numref:`figure5` shows a detailed message flow between the consumers and the
functional blocks inside the VIM and has the following steps:

Step 1: The consumer subscribes to capacity change notifications

Step 2: The Capacity Manager monitors the capacity information for the various
types of resources by querying the various Controllers (e.g. Nova, Neutron,
Cinder), either periodically or on demand and updates capacity information in
the Capacity Map

Step 3: Capacity changes are notified to the consumer

Step 4: The consumer queries the Capacity Manager to retrieve capacity detailed
information

Resource Reservation
^^^^^^^^^^^^^^^^^^^^

.. figure:: images/figure6.png
   :name: figure6
   :width: 90%

   Resource Reservation for Future Use Scenario

:numref:`figure6` shows a detailed message flow between the consumers and
the functional blocks inside the VIM and has the following steps:

Step 1: The consumer creates a resource reservation request for future use by
setting a start and end time for the allocation

Step 2: The consumer gets an immediate reply with a reservation status message
"reservationStatus" and an identifier to be used with this reservation instance
"reservationID"

Step 3: The consumer subscribes to reservation notification events

Step 4: The Resource Reservation Manager checks the feasibility of the
reservation request by consulting the Capacity Manager

Step 5: The Resource Reservation Manager reserves the resources and stores the
list of reservations IDs generated by the Controllers (e.g. Nova, Neutron,
Cinder) in the Reservation Map

Step 6: Once the reservation process is completed, the VIM sends a notification
message to the consumer with information on the reserved resources

Step 7: When start time arrives, the consumer creates a resource allocation
request.

Step 8: The consumer gets an immediate reply with an allocation status message
"allocationStatus".

Step 9: The consumer subscribes to allocation notification events

Step 10: The Resource Allocation Manager allocates the reserved resources. If
not all reserved resources are allocated before expiry, the reserved resources
are released and a notification is sent to the consumer

Step 11: Once the allocation process is completed, the VIM sends a notification
message to the consumer with information on the allocated resources
