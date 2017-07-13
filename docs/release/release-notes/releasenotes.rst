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

Abstract
===============

This document provides an overview of the Promise project in the OPNFV Euphrates
release. Promise is a resource reservation and management project to identify NFV related
requirements and realize resource reservation for future usage by capacity
management of resource pools regarding compute, network and storage.


Features
============

The following features are provided by the Promise in the OPNFV Euphrates release:

* Capacity Management
* Reservation Management
* Allocation Management

The Euphrates implementation of Promise is built with the YangForge data modeling
framework [#f2]_ , using a shim-layer on top of OpenStack to provide
the Promise features.

In the OPNFV Euphrates release cycle most efforts have been spend to progress the upstream
implementation of a native resource reservation system for OpenStack as part of the Blazar project.

Detailed information about Promise use cases, features, interface
specifications, work flows, and the underlying Promise YANG schema can be found
in the Promise requirement document [#f1]_ .

.. [#f1]_ http://artifacts.opnfv.org/promise/docs/development_requirements/index.html


Installer support and verification status
=========================================

Promise project is integrated in OPNFV through the Functest project (`FUNCTEST`_).

+-----------+--------------------------------------+--------------+
| Installer | Scenario                             | Status       |
+===========+======================================+==============+
| Fuel      | functest-fuel-baremetal-daily-master |              |
|           | functest-fuel-virtual-daily-master   |              |
+-----------+--------------------------------------+--------------+
| Joid      | functest-joid-baremetal-daily-master |              |
+-----------+--------------------------------------+--------------+

.. _FUNCTEST: https://wiki.opnfv.org/display/functest


Thereby, the following test cases (`TEST_CASES`_) are executed:

 - Reservation of a VM for immediate use followed by allocation
 - Reservation of a VM followed by denial of service to another user and by allocation of reserved VM
 - Reservation of a VM for future use
 - Update of an outstanding reservation - increase capacity
 - Update of an outstanding reservation - decrease capacity
 - Notification of reservation change
 - Cancellation of a reservation
 - Query of a reservation
 - Create a bulk reservation of compute capacity
 - Rejection of a reservation due to lack of resources
 - Reservation of block storage for future use
 - Capacity Management - query for available and used capacity
 - Capacity Management - notification on capacity changes
 - Global Promise suite

Note: 'Not verified' means that we didn't verify the functionality by having
our own test scenario running in OPNFV CI pipeline yet.

.. _TEST_CASES: http://testresults.opnfv.org/test/api/v1/projects/promise/cases


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
 - Promise requirements: http://artifacts.opnfv.org/promise/docs/development_requirements/index.html

Related Projects
----------------

 - OpenStack Blazar (Resource reservation for OpenStack): https://wiki.openstack.org/wiki/Blazar
 - YangForge data modeling framework: - https://github.com/opnfv/yangforge

Related ETSI NFV specifications
-------------------------------

 - ETSI NFV MANO GS: http://www.etsi.org/deliver/etsi_gs/NFV-MAN
 - ETSI NFV INF GSs: http://www.etsi.org/deliver/etsi_gs/NFV-INF
 - ETSI NFV IFA GSs: http://www.etsi.org/deliver/etsi_gs/NFV-IFA
