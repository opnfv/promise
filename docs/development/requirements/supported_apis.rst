.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

ANNEX C: Supported APIS
=======================

Add Provider
------------

Register a new resource provider (e.g. OpenStack) into reservation system.

Request parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
provider-type                Enumeration Name of the resource provider
endpoint                     URI         Targer URL end point for the resource provider
username                     String      User name
password                     String      Password
region                       String      Specified region for the provider
tenant.id                    String      Id of the tenant
tenant.name                  String      Name of the tenant
============================ =========== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
provider-id                  String      Id of the new resource provider
result                       Enumeration Result info
============================ =========== ==============================================

.. http:post:: /add-provider
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /add-provider HTTP/1.1
      Accept: application/json

      {
        "provider-type": "openstack",
        "endpoint": "http://10.0.2.15:5000/v2.0/tokens",
        "username": "promise_user",
        "password": "******",
        "tenant": {
           "name": "promise"
        }
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "provider-id": "f25ed9cb-de57-43d5-9b4a-a389a1397302",
        "result": "ok"
      }

Create Reservation
------------------

Make a request to the reservation system to reserve resources.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
zone                         String          Id to an availability zone
start                        DateTime        Timestamp when the consumption of reserved
                                             resources can begin
end                          DateTime        Timestamp when the consumption of reserved
                                             resources should end
capacity.cores               int16           Amount of cores to be reserved
capacity.ram                 int32           Amount of RAM to be reserved
capacity.instances           int16           Amount of instances to be reserved
capacity.addresses           int32           Amount of public IP addresses to be reserved
elements                     ResourceElement List of pre-existing resource elements
                                             to be reserved
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
reservation-id               String      Id of the reservation
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /create-reservation
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /create-reservation HTTP/1.1
      Accept: application/json

      {
         "capacity": {
            "cores": "5",
            "ram": "25600",
            "addresses": "3",
            "instances": "3"
         },
         "start": "2016-02-02T00:00:00Z",
         "end": "2016-02-03T00:00:00Z"
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "reservation-id": "269b2944-9efc-41e0-b067-6898221e8619",
        "result": "ok",
        "message": "reservation request accepted"
      }

Update Reservation
------------------

Update reservation details for an existing reservation.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
reservation-id               String          Id of the reservation to be updated
zone                         String          Id to an availability zone
start                        DateTime        Updated timestamp when the consumption of
                                             reserved resources can begin
end                          DateTime        Updated timestamp when the consumption of
                                             reserved resources should end
capacity.cores               int16           Updated amount of cores to be reserved
capacity.ram                 int32           Updated amount of RAM to be reserved
capacity.instances           int16           Updated amount of instances to be reserved
capacity.addresses           int32           Updated amount of public IP addresses
                                             to be reserved
elements                     ResourceElement Updated list of pre-existing resource elements
                                             to be reserved
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /update-reservation
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /update-reservation HTTP/1.1
      Accept: application/json

      {
         "reservation-id": "269b2944-9efv-41e0-b067-6898221e8619",
         "capacity": {
            "cores": "1",
            "ram": "5120",
            "addresses": "1",
            "instances": "1"
         }
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "result": "ok",
        "message": "reservation update successful"
      }

Cancel Reservation
------------------

Cancel the reservation.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
reservation-id               String          Id of the reservation to be canceled
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /cancel-reservation
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /cancel-reservation HTTP/1.1
      Accept: application/json

      {
        "reservation-id": "269b2944-9efv-41e0-b067-6898221e8619"
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "result": "ok",
        "message": "reservation canceled"
      }

Query Reservation
-----------------

Query the reservation system to return matching reservation(s).

Request parameters

============================ ================== ==============================================
Name                         Type               Description
============================ ================== ==============================================
zone                         String             Id to an availability zone
show-utilization             Boolean            Show capacity utilization
without                      ResourceCollection Excludes specified collection identifiers
                                                from the result
elements.some                ResourceElement    Query for ResourceCollection(s) that contain
                                                some or more of these element(s)
elements.every               ResourceElement    Query for ResourceCollection(s) that contain
                                                all of these element(s)
window.start                 DateTime           Matches entries that are within the specified
                                                start/end window
window.end                   DateTime
wndow.scope                  Enumeration        Matches entries that start {and/or} end
                                                within the time window
============================ ================== ==============================================

Response parameters

============================ =================== ================================
Name                         Type                Description
============================ =================== ================================
reservations                 ResourceReservation List of matching reservations
utilization                  CapacityUtilization Capacity utilization over time
============================ =================== ================================

.. http:post:: /query-reservation
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /query-reservation HTTP/1.1
      Accept: application/json

      {
         "show-utilization": false,
         "window": {
            "start": "2016-02-01T00:00:00Z",
            "end": "2016-02-04T00:00:00Z"
         }
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "reservations": [
          "269b2944-9efv-41e0-b067-6898221e8619"
        ],
        "utilization": []
      }

Create Instance
---------------

Create an instance of specified resource(s) utilizing capacity from the pool.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
provider-id                  String          Id of the resource provider
reservation-id               String          Id of the resource reservation
name                         String          Name of the instance
image                        String          Id of the image
flavor                       String          Id of the flavor
networks                     Uuid            List of network uuids
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
instance-id                  String      Id of the instance
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /create-instance
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /create-instance HTTP/1.1
      Accept: application/json

      {
        "provider-id": "f25ed9cb-de57-43d5-9b4a-a389a1397302",
        "name": "vm1",
        "image": "ddffc6f5-5c86-4126-b0fb-2c71678633f8",
        "flavor": "91bfdf57-863b-4b73-9d93-fc311894b902"
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "instance-id": "82572779-896b-493f-92f6-a63008868250",
        "result": "ok",
        "message": "created-instance request accepted"
      }

Destroy Instance
----------------

Destroy an instance of resource utilization and release it back to the pool.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
instance-id                  String          Id of the instance to be destroyed
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /destroy-instance
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /destroy-instance HTTP/1.1
      Accept: application/json

      {
         "instance-id": "82572779-896b-493f-92f6-a63008868250"
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
        "result": "ok",
        "message": "instance destroyed and resource released back to pool"
      }

Decrease Capacity
-----------------

Decrease total capacity for the reservation system for a given time window.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
source                       String          Id of the resource container
start                        DateTime        Start/end defines the time window when total
                                             capacity is decreased
end                          DateTime
capacity.cores               int16           Decreased amount of cores
capacity.ram                 int32           Decreased amount of RAM
capacity.instances           int16           Decreased amount of instances
capacity.addresses           int32           Decreased amount of public IP addresses
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
pool-id                      String      Id of the resource pool
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /decrease-capacity
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /decrease-capacity HTTP/1.1
      Accept: application/json

      {
         "source": "ResourcePool:4085f0da-8030-4252-a0ff-c6f93870eb5f",
         "capacity": {
            "cores": "3",
            "ram": "5120",
            "addresses": "1"
         }
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
         "pool-id": "c63b2a41-bcc6-42f6-8254-89d633e1bd0b",
         "result": "ok",
         "message": "capacity decrease successful"
      }

Increase Capacity
-----------------

Increase total capacity for the reservation system for a given time window.

Request parameters

============================ =============== ==============================================
Name                         Type            Description
============================ =============== ==============================================
source                       String          Id of the resource container
start                        DateTime        Start/end defines the time window when total
                                             capacity is increased
end                          DateTime
capacity.cores               int16           Increased amount of cores
capacity.ram                 int32           Increased amount of RAM
capacity.instances           int16           Increased amount of instances
capacity.addresses           int32           Increased amount of public IP addresses
============================ =============== ==============================================

Response parameters

============================ =========== ==============================================
Name                         Type        Description
============================ =========== ==============================================
pool-id                      String      Id of the resource pool
result                       Enumeration Result info
message                      String      Output message
============================ =========== ==============================================

.. http:post:: /increase-capacity
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /increase-capacity HTTP/1.1
      Accept: application/json

      {
         "source": "ResourceProvider:f6f13fe3-0126-4c6d-a84f-15f1ab685c4f",
         "capacity": {
             "cores": "20",
             "ram": "51200",
             "instances": "10",
             "addresses": "10"
         }
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 200 OK
      Content-Type: application/json

      {
         "pool-id": "279217a4-7461-4176-bf9d-66770574ca6a",
         "result": "ok",
         "message": "capacity increase successful"
      }

Query Capacity
--------------

Query for capacity information about a specified resource collection.

Request parameters

============================ ================== ==============================================
Name                         Type               Description
============================ ================== ==============================================
capacity                     Enumeration        Return total or reserved or available or
                                                usage capacity information
zone                         String             Id to an availability zone
show-utilization             Boolean            Show capacity utilization
without                      ResourceCollection Excludes specified collection identifiers
                                                from the result
elements.some                ResourceElement    Query for ResourceCollection(s) that contain
                                                some or more of these element(s)
elements.every               ResourceElement    Query for ResourceCollection(s) that contain
                                                all of these element(s)
window.start                 DateTime           Matches entries that are within the specified
                                                start/end window
window.end                   DateTime
window.scope                 Enumeration        Matches entries that start {and/or} end
                                                within the time window
============================ ================== ==============================================

Response parameters

============================ =================== ================================
Name                         Type                Description
============================ =================== ================================
collections                  ResourceCollection  List of matching collections
utilization                  CapacityUtilization Capacity utilization over time
============================ =================== ================================

.. http:post:: /query-capacity
   :noindex:

   **Example request**:

   .. sourcecode:: http

      POST /query-capacity HTTP/1.1
      Accept: application/json

      {
        "show-utilization": false
      }

   **Example response**:

   .. sourcecode:: http

      HTTP/1.1 201 CREATED
      Content-Type: application/json

      {
        "collections": [
          "ResourcePool:279217a4-7461-4176-bf9d-66770574ca6a"
        ],
        "utilization": []
      }

