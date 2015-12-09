Annex: Use case for OPNFV Brahmaputra
=================================================

A basic resource reservation use case to be realized for OPNFV B-release may 
look as follows:

* Step 0: Shim-layer is monitoring/querying available capacity at NFVI

  * Step 0a: Cloud operator creates a new OpenStack tenant user and  updates 
  quota values for this user

  * Step 0b: The tenant user is creating and instantiating a simple VNF (e.g. 
  1 network, 2 VMs)

  * Step 0c: OpenStack is notifying shim-layer about capacity change for this 
  new tenant user

  * Step 0d: Cloud operator can visualize the changes using the GUI

* Step 1: Consumer(NFVO) is sending a reservation request for future use to 
    shim-layer

* Step 2: Shim-layer is checking for available capacity at the given time 
    window

* Step 3: Shim-layer is responding with reservation identifier

* Step 4 (optional): Consumer(NFVO) is sending an update reservation request to
shim-layer (startTime set to now) -> continue with Steps 2 and 3.

* Step 5: Consumer(VNFM) is requesting the allocation of virtualised resources 
using the reservation identifier in Step 3