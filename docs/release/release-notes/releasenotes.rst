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

This document provides an overview of the Promise project in the OPNFV Euphrates
release.

Features
============

tbd


Installer support and verification status
=========================================

Integrated features
-------------------

tbd


OPNFV installer / scenario support matrix
-----------------------------------------

For Euphrates 1.0, Promise was tested on the following HA scenarios:

Promise project is integrated in OPNFV through Functest project (`FUNCTEST`_).

+-----------+--------------------------------------+--------------+
| Installer | Scenario                             | Status       |
+===========+======================================+==============+
| Fuel      | functest-fuel-baremetal-daily-master |              |
|           | functest-fuel-virtual-daily-master   |              |
+-----------+--------------------------------------+--------------+
| Joid      | functest-joid-baremetal-daily-master |              |
+-----------+--------------------------------------+--------------+

.. _FUNCTEST: https://wiki.opnfv.org/display/functest

Note: 'Not verified' means that we didn't verify the functionality by having
our own test scenario running in OPNFV CI pipeline yet.


Documentation updates
=====================

* **Update 1**

  tbd
  


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
 - OpenStack Blazar project (Resource reservation for OpenStack): https://wiki.openstack.org/wiki/Blazar
