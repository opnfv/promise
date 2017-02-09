.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

=================================
Gap analysis in upstream projects
=================================

This section provides a list of gaps in upstream projects for realizing
resource reservation and management. The gap analysis work focuses on the
current OpenStack Blazar project [BLAZAR]_ in this first release.

OpenStack
=========

Resource reservation for future use
-----------------------------------

* Category: Blazar
* Type: 'missing' (lack of functionality)
* Description:

  * To-be: To reserve a whole set of compute/storage/network resources in the
    future
  * As-is: Blazar currently can do only compute resource reservation by using
    "Shelved VM"

* Related blueprints:

  * https://blueprints.launchpad.net/blazar/+spec/basic-volume-plugin
  * https://blueprints.launchpad.net/blazar/+spec/basic-network-plugin
  * It was planned in Blazar to implement volume and network/fixed ip
    reservations

Resource reservation update
---------------------------

* Category: Blazar
* Type: 'missing' (lack of functionality)
* Description:

  * To-be: Have the possibility of adding/removing resources to an existing
    reservation, e..g in case of NFVI failure
  * As-is: Currently in Blazar, a reservation can only be modified in terms of
    start/end time

* Related blueprints: N/A

Give me an offer
----------------

* Category: Blazar
* Type: 'missing' (lack of functionality)
* Description:

  * To-be: To have the possibility of giving a quotation to a requesting user
    and an expiration time. Reserved resources shall be released if they are
    not claimed before this expiration time.
  * As-is: Blazar can already send notification e.g. to inform a given user
    that a reservation is about to expire

* Related blueprints: N/A

StormStack StormForge
---------------------

Stormify
^^^^^^^^
* Stormify enables rapid web applications construction
* Based on Ember.js style Data stores
* Developed on Node.js using coffeescript/javascript
* Auto RESTful API generation based on Data Models
* Development starts with defining Data Models
* Code hosted at github : http://github.com/stormstack/stormify

StormForge
^^^^^^^^^^
* Data Model driven management of Resource Providers
* Based on Stormify Framework and implemented as per the OPNFV Promise
  requirements
* Data Models are auto generated and RESTful API code from YANG schema
* Currently planned key services include Resource Capacity Management Service
  and Resource Reservation Service
* List of YANG schemas for Promise project is attached in the Appendix
* Code hosted at github: http://github.com/stormstack/stormforge

Resource Discovery
^^^^^^^^^^^^^^^^^^
* Category: StormForge
* Type: 'planning' (lack of functionality)
* Description

  * To-be: To be able to discover resources in real time from OpenStack
    components. Planning to add OpenStack Project to interface with Promise for
    real time updates on capacity or any failures
  * As-is: Currently, resource capacity is learnt using NB APIs related to
    quota

* Related Blueprints: N/A

