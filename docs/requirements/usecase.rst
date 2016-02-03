.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
=======================
Use cases and scenarios
=======================

Resource reservation is a basic feature in any virtualization-based network
operation. In order to perform such resource reservation from NFVO to VIM, NFVI
capacity information is also necessary at the NFVO side. Below, four use cases
to show typical requirements and solutions for capacity management and resource
reservation is presented. A typical use case as considered for the Brahmaputra
release is described in :ref:`uc-brahmaputra`.

#.  Resource capacity management
#.  Resource reservation for immediate use
#.  Resource reservation for future use
#.  Co-existence of reservations and allocation requests without reservation

Resource capacity management
============================

NFVO takes the first decision on in which NFVI it would instantiate a VNF. Along
with NFVIs resource attributes (e.g. availability of hardware accelerators,
particular CPU architectures etc.), NFVO needs to know available capacity of an
NFVI in order to make an informed decision on selecting a particular NFVI. Such
capacity information shall be in a coarser granularity than the respective VIM,
as VIM maintains capacity information of its NFVI in fine details.  However a
very coarse granularity, like simply the number of available virtual CPU cores,
may not be sufficient. In order to allow the NFVO to make well founded
allocation decisions, an appropriate level to expose the available capacity may
be per flavor. Capacity information may be required for the complete NFVI, or
per partition or availability zone, or other granularities. Therefore, VIM
requires to inform the NFVO about available capacity information regarding its
NFVI at a pre-determined abstraction, either by a query-response, or in an
event-based, or in a periodical way.

Resource reservation for immediate use
======================================

Reservation is inherently for the future. Even if some reserved resources are to
be consumed instantly, there is a network latency between the issuance of a
resource reservation request from the NFVO, a response from the VIM, and actual
allocation of the requested resources to a VNF/VNFM. Within such latency,
resource capacity in the NFVI in question could change, e.g., due to failure,
allocation to a different request. Therefore, the response from a VIM to the
NFVO to a resource reservation request for immediate use should have a validity
period which shows until when this VIM can hold the requested resources. During
this time, the NFVO should proceed to allocation if it wishes to consume the
reserved requested. If allocation is not performed within the validity period,
the response from VIM for a particular resource reservation request becomes
invalid and VIM is not liable to provide those resources to NFVO/VNFM anymore.
Reservations requests for immediate use do not have a start time but may have
an end time.

Resource reservation for future use
===================================

Network operators may want to reserve extra resources for future use. Such
necessity could arise from predicted congestion in telecom nodes e.g. due to
local traffic spikes for concerts, natural disasters etc. In such a case, the
NFVO, while sending a resource reservation request to the VIM, shall include a
start time (and an end time if necessary). The start time indicates at what
time the reserved resource shall be available to a designated consumer e.g. a
VNF/VNFM. Here, the requirement is that the reserved resources shall be
available when the start time arrives. After the start time has arrived, the
reserved resources are allocated to the designated consumer(s). An explicit
allocation request is needed. How actually these requested resources are held
by the VIM for the period in between the arrival of the resource reservation
request and the actual allocation is outside the scope of this requirement
project.

Co-existence of reservations and allocation requests without reservation
========================================================================

In a real environment VIM will have to handle allocation requests without any
time reference, i.e. time-unbound, together with time-bound reservations and
allocation requests with an explicitly indicated end-time. A granted
reservation for the future will effectively reduce the available capacity for
any new time-unbound allocation request. The consequence is that reservations,
even those far in the future, may result in denial of service for new
allocation requests.

To alleviate this problem several approaches can be taken. They imply an
implicit or explicit priority scheme:

* Allocation requests without reservation and which are time-unbound will be
  granted resources in a best-effort way: if there is instant capacity, but the
  resources may be later withdrawn due to the start time of a previously
  granted reservation
* Both allocation requests and reservation requests contain a priority which
  may be related to SLAs and contractual conditions between the tenant and the
  NFVI provider. Interactions may look like:

  * A reservation request for future use may cancel another, not yet
    started, reservation with lower priority
  * An allocation request without reservations and time-unbound [#unbound]_
    may be granted resources and prevent a future reservation with lower
    priority from getting resources at start time
  * A reservation request may result in terminating resources allocated to a
    request with no reservation, if the latter has lower priority

.. [#unbound] In this case, the consumer (VNFM or NFVO) requests to immediately
              instantiate and assign virtualized resources without having
              reserved the resources beforehand
