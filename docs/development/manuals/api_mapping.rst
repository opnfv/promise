.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

=======================================
Resource reservation mapping tables
=======================================

The following tables are an attempt to map the resource reservation APIs / interfaces between ETSI
NFV-IFA005 and Blazar for OpenStack.

I. Create Compute Resource Reservation
======================================

I.a) Create compute pool/resources reservation REQUEST
------------------------------------------------------

+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                | Blazar                                | Description                                    | Comment                                         |
+==+=============================+=+=====================================+================================================+=================================================+
| \-                             | name                                  | Name of the lease/reservation.                 |                                                 |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| computePoolReservation [1]:    | **reservations**:                     |                                                | **Instance reservation is only available        |
| **ComputePoolReservation**     | resource_type = 'virtual:instance'    |                                                | from OpenStack Pike release.**                  |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
|  | \-                          | | amount                              | Amount of virtual instances of a given         |                                                 |
|  |                             | |                                     | flavour to be reserved.                        |                                                 |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
|  | numCpuCores [1]: Integer    | | vcpus                               | Number of vCPU cores to be reserved.           |                                                 |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
|  | numVcInstances [1]:         | | \-                                  | Number of virtualized container instances to   |                                                 |
|  | Integer                     | |                                     | be reserved (without explicitly reserved       |                                                 |
|  |                             | |                                     | specific virtual containers).                  |                                                 |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
|  | virtualMemSize [1]: Number  | | memory_mb                           | Size of virtual memory to be reserved.         |                                                 |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
|  | \-                          | | disk_gb                             | Size of (disk) storage to be reserved.         |                                                 |
+--+-----------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
|  | computeAttributes [0..1]:   | | \-                                  | Information specifying additional attributes   | Not yet available in Pike release.              |
|  | VirtualComputeAttributes    | |                                     | of the compute resource to be reserved.        |                                                 |
|  | ReservationData             | |                                     |                                                |                                                 |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| affinityConstraint [0..N]:     | | affinity: Boolean                   | Element with (anti-)affinity information of    | Only boolean (anti-)affinity rule in            |
| AffinityOrAnti                 | |                                     | the virtualised compute resources to reserve.  | Pike release.                                   |
| AffinityConstraint             | |                                     | For the resource reservation at resource       |                                                 |
|                                | |                                     | pool granularity level, it defines the         |                                                 |
+--------------------------------+ +                                     + (anti-)affinity information of the virtual     +                                                 +
| antiAffinityConstraint [0..N]: | |                                     | compute pool resources to reserve. For         |                                                 |
| AffinityOrAnti                 | |                                     | the resource reservation at virtual            |                                                 |
| AffinityConstraint             | |                                     | container granularity level, it defines        |                                                 |
|                                | |                                     | the (anti-)affinity information of the         |                                                 |
|                                | |                                     | virtualisation container(s) to reserve.        |                                                 |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| startTime [0..1]: TimeStamp    | start_date [0..1]: DateTime           | Timestamp indicating the earliest time to      | Resources are reserved for immediate use if:    |
|                                |                                       | start the consumption of the resources.        |                                                 |
|                                |                                       |                                                | * (Blazar) the start_date parameter is omitted  |
|                                |                                       |                                                | * (ETSI NFV IFA005) the startTime value is 0    |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| endTime [0..1]: TimeStamp      | end_date [0..1]: DateTime             | Timestamp indicating the end time of the       | * (ETSI NFV IFA005) If the attribute is not     |
|                                |                                       | reservation (when the issuer of the request    |   present, resources are reserved for unlimited |
|                                |                                       | expects that the resources will no longer be   |   usage time.                                   |
|                                |                                       | needed) and used by the VIM to schedule the    | * (Blazar) If the parameter is not present,     |
|                                |                                       | reservation.                                   |   resources are reserved for 24h after the      |
|                                |                                       |                                                |   start_date.                                   |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| expiryTime [0..1]: TimeStamp   | \-                                    | Timestamp indicating the time the VIM can      | Not yet available in Pike release.              |
|                                |                                       | release the reservation in case no allocation  |                                                 |
|                                |                                       | request against this reservation was made.     |                                                 |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| \-                             | before_end_notification               | Timestamp indicating when the                  | * (ETSI NFV IFA005) not specified               |
|                                |                                       | *before_end action* will be executed, e.g.     | * (Blazar) Not yet implemented for pool/        |
|                                |                                       | take a snapshot of the resources of the lease. |   resources reservation, but only host          |
|                                |                                       |                                                |   reservations.                                 |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| locationConstraints [0..1]:    | \-                                    | If present, it defines location constraints    | Not yet available in Pike release.              |
| \-*tbd*\-                      |                                       | for the resource(s) is (are) requested to be   |                                                 |
|                                |                                       | reserved, e.g. in what particular Resource     |                                                 |
|                                |                                       | Zone.                                          |                                                 |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+
| resourceGroupId [0..1]:        | project_id: Identifier                | Unique identifier of the "infrastructure       |                                                 |
| Identifier                     |                                       | resource group", logical grouping of virtual   |                                                 |
|                                |                                       | resources assigned to a tenant within an       |                                                 |
|                                |                                       | Infrastructure Domain.                         |                                                 |
+--------------------------------+-+-------------------------------------+------------------------------------------------+-------------------------------------------------+

.. note::  In Blazar reservations are encapsulated in leases, whereby one lease can have several reservations (i.e. reserved resources) with the same start and end dates.

.. note::  In the reservation system (e.g. Blazar) each lease/reservation has additional implementation level attributes not listed in the mapping tables in this document, e.g. lease_id, status, status reason, action, …, and which are not included in reservation requests.

I.b) Create virtualisation container reservation REQUEST
--------------------------------------------------------

+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                           | Blazar                                | Description                                      | Comment                                         |
+==+========================================+=+=====================================+==================================================+=================================================+
| \-                                        | name                                  | Name of the lease/reservation.                   |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|                                           | **reservations**                      |                                                  |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|                                           | | resource_type = '...'               |                                                  |                                                 +
|                                           | |                                     |                                                  |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| virtualisationContainerReservation        | |                                     | Virtualisation containers that need to be        |                                                 |
| [0..N]:                                   | |                                     | reserved (e.g. following a specific compute      |                                                 |
|                                           | |                                     | "flavour").                                      |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | **VirtualisationContainerReservation** | |                                     |                                                  |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | containerId [1]: Identifier            | |                                     | Identifier given to the compute flavour.         |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | flavourId [1]: Identifier              | |                                     | The containerFlavour encapsulates information    |                                                 |
|  |                                        | |                                     | of the virtualisation container to be reserved.  |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | accelerationCapability [0..N]:         | |                                     | Selected acceleration capabilities (e.g. crypto, |                                                 |
|  | \-*tbd*\-                              | |                                     | GPU) from the set of capabilities offered by the |                                                 |
|  |                                        | |                                     | compute node acceleration resources.             |                                                 |
|  |                                        | |                                     | The cardinality can be 0, if no particular       |                                                 |
|  |                                        | |                                     | acceleration capability is requested.            |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | virtualMemory [1]: VirtualMemoryData   | |                                     | Virtual memory of the virtualised compute.       |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | virtualCpu [1]: VirtualCpuData         | |                                     | Virtual CPU(s) of the virtualised compute.       |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | storageAttributes [0..N]:              | |                                     | Element containing information about the size of |                                                 |
|  | VirtualStorageData                     | |                                     | virtualised storage resource (e.g. size of       |                                                 |
|  |                                        | |                                     | volume, in GB), the type of storage (e.g.,       |                                                 |
|  |                                        | |                                     | volume, object), and support for RDMA.           |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
|  | virtualNetworkInterface [0..N]:        | |                                     | Virtual network interfaces of the virtualised    |                                                 |
|  | VirtualNetworkInterface                | |                                     | compute.                                         |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| affinityConstraint [0..N]:                | | affinity: Boolean                   | Element with (anti-)affinity information of      | Affinity and AntiAffinity rules are not yet     |
| AffinityOrAntiAffinityConstraint          | |                                     | the virtualised compute resources to reserve.    | available in Pike release.                      |
|                                           | |                                     | For the resource reservation at resource         |                                                 |
|                                           | |                                     | pool granularity level, it defines the           |                                                 |
+--+----------------------------------------+ +                                     + (anti-)affinity information of the virtual       +                                                 +
| antiAffinityConstraint [0..N]:            | |                                     | compute pool resources to reserve. For           |                                                 |
| AffinityOrAntiAffinityConstraint          | |                                     | the resource reservation at virtual              |                                                 |
|                                           | |                                     | container granularity level, it defines          |                                                 |
|                                           | |                                     | the (anti-)affinity information of the           |                                                 |
|                                           | |                                     | virtualisation container(s) to reserve.          |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| startTime [0..1]: TimeStamp               | start_date [0..1]: DateTime           | Timestamp indicating the earliest time to        | Resources are reserved for immediate use if:    |
|                                           |                                       | start the consumption of the resources.          |                                                 |
|                                           |                                       |                                                  | * (Blazar) the start_date parameter is omitted  |
|                                           |                                       |                                                  | * (ETSI NFV IFA005) the startTime value is 0    |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| endTime [0..1]: TimeStamp                 | end_date [0..1]: DateTime             | Timestamp indicating the end time of the         | * (ETSI NFV IFA005) If the attribute is not     |
|                                           |                                       | reservation (when the issuer of the request      |   present, resources are reserved for unlimited |
|                                           |                                       | expects that the resources will no longer be     |   usage time.                                   |
|                                           |                                       | needed) and used by the VIM to schedule the      | * (Blazar) If the parameter is not present,     |
|                                           |                                       | reservation.                                     |   resources are reserved for 24h after the      |
|                                           |                                       |                                                  |   start_date.  **to be checked**                |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| expiryTime [0..1]: TimeStamp              | \-                                    | Timestamp indicating the time the VIM can        | Not yet available in Pike release.              |
|                                           |                                       | release the reservation in case no allocation    |                                                 |
|                                           |                                       | request against this reservation was made.       |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| \-                                        | before_end_notification               | Timestamp indicating when the                    |                                                 |
|                                           |                                       | *before_end action* will be executed, e.g.       |                                                 |
|                                           |                                       | take a snapshot of the resources of the lease.   |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| locationConstraints [0..1]:               | \-                                    | If present, it defines location constraints for  | Not yet available in Pike release.              |
| \-*tbd*\-                                 |                                       | the resource(s) is (are) requested to be         |                                                 |
|                                           |                                       | reserved, e.g. in what particular Resource Zone. |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+
| resourceGroupId [0..1]:                   | project_id: Identifier                | Unique identifier of the "infrastructure         |                                                 |
| Identifier                                |                                       | resource group", logical grouping of virtual     |                                                 |
|                                           |                                       | resources assigned to a tenant within an         |                                                 |
|                                           |                                       | Infrastructure Domain.                           |                                                 |
+--+----------------------------------------+-+-------------------------------------+--------------------------------------------------+-------------------------------------------------+

I.c) Create reservation RESPONSE
--------------------------------

+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                        | Blazar                                | Description                                         | Comment                                         |
+==+=+===================================+=+=====================================+=====================================================+=================================================+
| **ReservedVirtualCompute** [1]:        | **reservations**                      |                                                     |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | computePoolReserved [0..1]:         | | resource_type = ‘virtual:instance’  | Information about compute resources that have been  | **Instance reservation is available from        |
|  | **ReservedComputePool**             | |                                     | reserved, e.g. {"cpu_cores":90, "vm_instances":10,  | Pike release.**                                 |
|  |                                     | |                                     | "ram":10000}.                                       |                                                 |
|  |                                     | |                                     | In Blazar resource_type = ‘virtual:instance’        |                                                 |
|  |                                     | |                                     | if the reservation was for virtual instances.       |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | \-                                | | id                                  | Identifier of the reservation.                      |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | \-                                | | lease-id                            | Identifier of the corresponding lease.              |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | \-                                | | resource_id                         | ??                                                  |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | \-                                | | amount                              | Amount of virtual instances of a given flavour that |                                                 |
|  | |                                   | |                                     | have been reserved.                                 |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | numVcInstances [1]: Integer       | | \-                                  | Number of virtual container instances that have     |                                                 |
|  | |                                   | |                                     | been reserved.                                      |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | numCpuCores [1]: Integer          | | vcpus                               | Number of CPU cores that have been reserved.        |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | virtualMemSize [1]: Number        | | memory_mb                           | Size of virtual memory that has been reserved.      |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | \-                                | | disk_gb                             | Size of (disk) storage that has been reserved.      |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | \-                                | | affinity: Boolean                   | Affinity information of the reserved resources.     | (NFV-IFA005) no such information is returned.   |
|  | |                                   | |                                     |                                                     | Recommendation to add this attribute to the     |
|  | |                                   | |                                     |                                                     | response message.                               |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | computeAttributes [0..1]:         | | \-                                  | Information specifying additional attributes of     |                                                 |
|  | | VirtualComputeAttributes          | |                                     | the virtual compute resource that have been         |                                                 |
|  | | ReservationData                   | |                                     | reserved.                                           |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | virtualisationContainerReserved     | |                                     | Information about the virtualisation                |                                                 |
|  | [0..N]: **ReservedVirtualisation    | |                                     | container(s) that have been reserved.               |                                                 |
|  | Container**                         | |                                     |                                                     |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | containerId [1]: Identifier       | |                                     | Identifier of the virtualisation container that has |                                                 |
|  | |                                   | |                                     | been reserved.                                      |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | flavourId [1]: Identifier         | |                                     | Identifier of the given compute flavour used in the |                                                 |
|  | |                                   | |                                     | reserved virtualisation container.                  |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | accelerationCapability [0..N]:    | |                                     | Selected acceleration capabilities (e.g. crypto,    |                                                 |
|  | | \-*tbd*\-                         | |                                     | GPU) from the set of capabilities offered by the    |                                                 |
|  | |                                   | |                                     | compute node acceleration resources.                |                                                 |
|  | |                                   | |                                     | The cardinality can be 0, if no particular          |                                                 |
|  | |                                   | |                                     | acceleration capability is provided.                |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | virtualMemory [1]:                | |                                     | Virtual memory of the reserved virtualisation       |                                                 |
|  | | VirtualMemoryData                 | |                                     | container.                                          |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | virtualCpu [1]:                   | |                                     | Virtual CPU(s) of the reserved virtualisation       |                                                 |
|  | | VirtualCpuData                    | |                                     | container.                                          |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | virtualDisks [0..N]:              | |                                     | Element with information of the virtualised storage |                                                 |
|  | | VirtualStorage                    | |                                     | resources attached to the reserved virtualisation   |                                                 |
|  | |                                   | |                                     | container.                                          |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | virtualNetworkInterface [0..N]:   | |                                     | Element with information of the virtual network     |                                                 |
|  | | VirtualNetworkInterface           | |                                     | interfaces of the reserved virtualisation container |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | | zoneId [0..1]:                    | |                                     | References the resource zone where the              |                                                 |
|  | | Identifier (reference to          | |                                     | virtualisation container has been reserved.         |                                                 |
|  | | ResoureZone)                      | |                                     | Cardinality can be 0 to cover the case where        |                                                 |
|  | |                                   | |                                     | reserved network resources are not bound to a       |                                                 |
|  | |                                   | |                                     | specific resource zone.                             |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | reservationStatus [1]: Enum         | | status;                             | Status of the compute resource reservation, e.g.    |                                                 |
|  |                                     | | status_reason                       | to indicate if a reservation is being used          |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | startTime [0..1]: TimeStamp         | | start_date [1]                      | Indication when the consumption of the resources    |                                                 |
|  |                                     | |                                     | starts. If the value is 0, resources are reserved   |                                                 |
|  |                                     | |                                     | for immediate use.                                  |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | endTime [0..1]: TimeStamp           | | end_date [1]                        | Indication when the reservation ends (when it is    |                                                 |
|  |                                     | |                                     | expected that the resources will no longer be       |                                                 |
|  |                                     | |                                     | needed) and used by the VIM to schedule the         |                                                 |
|  |                                     | |                                     | reservation. If not present, resources are reserved |                                                 |
|  |                                     | |                                     | for unlimited usage time.                           |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | expiryTime [0..1]: TimeStamp        | | \-                                  | Indication when the VIM can release the reservation |                                                 |
|  |                                     | |                                     | in case no allocation request against this          |                                                 |
|  |                                     | |                                     | reservation was made.                               |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+
|  | \-                                  | | events                              |                                                     |                                                 |
+--+-+-----------------------------------+-+-------------------------------------+-----------------------------------------------------+-------------------------------------------------+

II. Query / list compute resource reservation
=============================================

II.a) REQUEST
----------------

+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                  | Blazar                               | Description                                    | Comment                                         |
+==================================+======================================+================================================+=================================================+
| queryReservationFilter [1]:      | lease_id                             | Query filter based on e.g. name, identifier,   | Blazar does not yet allow to list leases based  |
| Filter                           |                                      | meta-data information or status information    | on a filter. In Blazar you can either list all  |
|                                  |                                      | expressing the type of information to be       | leases registered in Blazar (GET /v1/leases) or |
|                                  |                                      | retrieved. It can also be used to specify one  | show information about a specific lease         |
|                                  |                                      | or more reservations to be queried by          | (GET /v1/leases/{lease-id}).                     |
|                                  |                                      | providing their identifiers.                   |                                                 |
+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+


II.a) RESPONSE
----------------

+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                  | Blazar                               | Description                                    | Comment                                         |
+==================================+======================================+================================================+=================================================+
| queryResult [0..N]:              | leases{ reservations {..} }          | Element containing information about the       | For attributes of ReservedVirtualCompute        |
| ReservedVirtualCompute           |                                      | reserved resource. Cardinality is 0 if the     | see clause I.c.                                 |
|                                  |                                      | query did not return any result.               |                                                 |
+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+


III. Update compute resource reservation
=============================================

III.a) REQUEST
----------------

+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                    | Blazar                               | Description                                         | Comment                                         |
+====================================+======================================+=====================================================+=================================================+
| reservationId [1]: Id              | lease_id                             | Identifier of the existing resource                 |                                                 |
|                                    |                                      | reservation to be updated.                          |                                                 |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| \-                                 | name                                 | Name of the lease/reservation.                      |                                                 |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| computePoolReservation [0..1]:     | \-                                   | New amount of compute resources to be reserved.     | For attributes of ComputePoolReservation see    |
| ComputePoolReservation             |                                      |                                                     | clause I.a.                                     |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| virtualisationContainer            | \-                                   | New virtualisation containers to be reserved        | For attributes of                               |
| Reservation [0..N]:                |                                      | (e.g. following a specific compute "flavour").      | VirtualisationContainerReservation see          |
| VirtualisationContainerReservation |                                      |                                                     | clause I.b.                                     |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| startTime [0..1]: TimeStamp        | \-                                   | Indication when the consumption of the resources    |                                                 |
|                                    |                                      | resources starts. If not present, the original      |                                                 |
|                                    |                                      | setting will not be changed. If present and the     |                                                 |
|                                    |                                      | value is 0, resources are reserved for              |                                                 |
|                                    |                                      | immediate use.                                      |                                                 |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| endTime [0..1]: TimeStamp          | end_date                             | Indication when the reservation ends (when it is    |                                                 |
|                                    |                                      | expected that the resources will no longer be       |                                                 |
|                                    |                                      | needed) and used by the VIM to schedule the         |                                                 |
|                                    |                                      | reservation. If not present, resources are reserved |                                                 |
|                                    |                                      | for unlimited usage time.                           |                                                 |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+
| expiryTime [0..1]: TimeStamp       | \-                                   | Indication when the VIM can release the reservation |                                                 |
|                                    |                                      | in case no allocation request against this          |                                                 |
|                                    |                                      | reservation was made.                               |                                                 |
+------------------------------------+--------------------------------------+-----------------------------------------------------+-------------------------------------------------+

.. note::  In Blazar it is only name modification and prolonging are possible.

III.a) RESPONSE
----------------

+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                  | Blazar                               | Description                                    | Comment                                         |
+==================================+======================================+================================================+=================================================+
| reservationData [0..N]:          | leases { reservations {..} }         | Element containing information about the       | For attributes of ReservedVirtualCompute and    |
| ReservedVirtualCompute           |                                      | updated reserved resource.                     | Blazar reservations see clause I.c.             |
+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+


IV. Terminate compute resource reservation
=============================================

IV.a) REQUEST
---------------

+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                  | Blazar                               | Description                                    | Comment                                         |
+==================================+======================================+================================================+=================================================+
| reservationId [1..N]: Identifier | lease_id                             | Identifier of the resource reservation(s) to   |                                                 |
|                                  |                                      | terminate.                                     |                                                 |
+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+


IV.a) RESPONSE
----------------

+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+
| ETSI NFV IFA005                  | Blazar                               | Description                                    | Comment                                         |
+==================================+======================================+================================================+=================================================+
| reservationId [1..N]: Identifier | \-                                   | Identifier of the resource reservation(s)      | Blazar just returns a HTTP/1.1 204 NO CONTENT   |
|                                  |                                      | successfullly terminated.                      | response code.                                  |
+----------------------------------+--------------------------------------+------------------------------------------------+-------------------------------------------------+
