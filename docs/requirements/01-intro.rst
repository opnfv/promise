
============
Introduction
============

Resource reservation is a basic function for the operation of a virtualized
telecom network. In resource reservation, VIM reserves resources for a certain
period as requested by the NFVO. A resource reservation will have a start time
which could be into the future. Therefore, the reserved resources shall be
available for the NFVO requested purpose (e.g. for a VNF) at the start time for
the duration asked by NFVO. Resources include all three resource types in an
NFVI i.e. compute, storage and network.

Besides, NFVO requires abstracted NFVI resource capacity information in order
to take decisions on VNF placement and other operations related to the virtual
resources. VIM is required to inform the NFVO of NFVI resource state
information for this purpose. Promise project aims at delivering the detailed
requirements on these two features defined in ETSI NFV MAN GS :ref:[NFVMAN],
the list of gaps in upstream projects, potential implementation architecture
and plan, and the VIM northbound interface specification for resource
reservation and capacity management.

Problem description
===================

OpenStack, a prominent candidate for the VIM, cannot reserve resources for
future use. OpenStack requires immediate instantiation of Virtual Machines
(VMs) in order to occupy resources intended to be reserved. Blazar can reserve
compute resources for future by keeping the VMs in shelved mode. However, such
reserved resources can also be used for scaling out rather than new VM
instantiation. Blazar does not support network and storage resource reservation
yet.

Besides, OpenStack does not provide a northbound interface through which it can
notify an upper layer management entity e.g. NFVO about capacity changes in its
NFVI, periodically or in an event driven way. Capacity management is a feature
defined in ETSI NFV MAN GS :ref:[NFVMAN] and is required in network operation.
