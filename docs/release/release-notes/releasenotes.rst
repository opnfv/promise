.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

=======================================
OPNFV Promise release notes (Euphrates)
=======================================

Version history
===============

+------------+---------------+-----------------+-------------+
| **Date**   | **Ver.**      | **Author**      | **Comment** |
+============+===============+=================+=============+
| 2017-07-13 | Euphrates 1.0 | Gerald Kunzmann |             |
+------------+---------------+-----------------+-------------+

Important notes
===============

**Attention:** Please be aware that the Promise shim-layer implementation is marked as DEPRECATED
in Euphrates and both implementation and related test cases may be removed from next release.

Abstract
========

This document provides an overview of the Promise project in the OPNFV Euphrates
release. Promise is a resource reservation and management project to identify NFV related
requirements and realize resource reservation for future usage by capacity
management of resource pools regarding compute, network and storage.


Features
========

The following features are provided by the Promise in the OPNFV Euphrates release:

* Capacity Management
* Reservation Management
* Allocation Management

The Euphrates implementation of Promise is built with the YangForge data modeling
framework [#f2]_ , using a shim-layer on top of OpenStack to provide
the Promise features.

In the OPNFV Euphrates release cycle most efforts have been spent to progress the upstream
implementation of a native resource reservation system for OpenStack as part of the Blazar project
[#f3]_.

Detailed information about Promise use cases, features, interface
specifications, work flows, and the underlying Promise YANG schema can be found
in the Promise requirement document [#f1]_ .

.. [#f1]_ :ref:`<promise-requirements>`
.. [#f2]_ https://github.com/opnfv/yangforge
.. [#f3]_ https://launchpad.net/blazar/+milestone/0.3.0


Installer support and verification status
=========================================

Promise project is integrated in OPNFV through the Functest project (`FUNCTEST`_).

+-----------+----------------------------------------------+--------------+
| Installer | CI Job                                       | Status       |
+===========+==============================================+==============+
| Fuel      | functest-fuel-baremetal-daily-master         |              |
|           | functest-fuel-virtual-daily-master           |              |
|           | functest-fuel-armband-baremetal-daily-master |              |
+-----------+----------------------------------------------+--------------+
| Joid      | functest-joid-baremetal-daily-master         |              |
+-----------+----------------------------------------------+--------------+

.. _FUNCTEST: https://wiki.opnfv.org/display/functest


Thereby, the following test cases (`TEST_CASES`_) are executed:

 - Add a new OpenStack provider to the reservation service
 - Allocation of resources without prior reservation
 - Reservation of a VM for immediate use followed by allocation
 - Reservation of a VM for future use
 - Update reservation
 - Query reservation
 - Cancel reservation
 - Error case: try to create reservation with a conflict
 - Capacity management - increase/decrease available capacity of a provider
 - Capacity Management - query for available and used capacity


.. _TEST_CASES: https://git.opnfv.org/promise/tree/source/test/promise-intents.coffee


Open JIRA tickets
=================

+------------------+-----------------------------------------------+
|   JIRA           |         Description                           |
+==================+===============================================+
|                  |                                               |
|                  |                                               |
+------------------+-----------------------------------------------+

All the tickets that are not blocking have been fixed or postponed
the next release.

Promise Euphrates 1.0 is released without known bugs.



Useful links
============

 - Promise project page: https://wiki.opnfv.org/display/promise
 - :ref:`Promise requirements: <promise-requirements>`

Related Projects
----------------

 - OpenStack Blazar (Resource reservation for OpenStack): https://docs.openstack.org/blazar/latest/
 - YangForge data modeling framework: - https://github.com/opnfv/yangforge

Related ETSI NFV specifications
-------------------------------

 - ETSI NFV MANO GS: http://www.etsi.org/deliver/etsi_gs/NFV-MAN
 - ETSI NFV INF GSs: http://www.etsi.org/deliver/etsi_gs/NFV-INF
 - ETSI NFV IFA GSs: http://www.etsi.org/deliver/etsi_gs/NFV-IFA
