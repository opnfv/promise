.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0


This document provides the release notes for Gambia of Promise.

Important notes
===============

**Attention:** Please be aware that Promise is transitioning to OpenStack
Blazar. The integration of Blazar to OPNFV is done via OpenStack Ansible.


Summary
=======

Promise is a resource reservation and management project to identify NFV related
requirements and realize resource reservation for future usage by capacity
management of resource pools regarding compute, network and storage.
The resource reservation functionality is developed further in Blazar, a native
resource reservation system for OpenStack `Blazar docs`_.

In the OPNFV Gambia release cycle most efforts have been spent to progress the
upstream development in the Blazar project as well as its integration to OPNFV
via OpenStack Ansible.


Version change
^^^^^^^^^^^^^^

Module version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- The Promise implementation has been replaced by the upstream OpenStack Blazar
project.

Document version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- The Promise user guide has been removed. Please instead refer to the OpenStack Blazar
documentation `Blazar docs`_.

- The Promise config guide has been updated accordingly.


Known Limitations, Issues and Workarounds
=========================================

Please refer to the Blazar features page `Blazar features`_ for features that
are planned for upcoming releases of the OpenStack Blazar project.

Refer to the Blazar bug tracker `Blazar bugs`_ for known issues with the current
OpenStack Blazar implementation.


.. _`Blazar docs`: https://docs.openstack.org/blazar/latest/
.. _`Blazar features`: https://blueprints.launchpad.net/blazar
.. _`Blazar bugs`: https://bugs.launchpad.net/blazar


References
==========

Useful links
^^^^^^^^^^^^

 - Promise project page: https://wiki.opnfv.org/display/promise
 - :ref:`Promise requirements: <promise-requirements>`
 - OpenStack Blazar (Resource reservation for OpenStack): https://docs.openstack.org/blazar/latest/

Related ETSI NFV specifications
-------------------------------

 - ETSI NFV MANO GS: http://www.etsi.org/deliver/etsi_gs/NFV-MAN
 - ETSI NFV INF GSs: http://www.etsi.org/deliver/etsi_gs/NFV-INF
 - ETSI NFV IFA GSs: http://www.etsi.org/deliver/etsi_gs/NFV-IFA
