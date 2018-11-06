.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

Blazar installation with OpenStack Ansible
==========================================
.. note::
   This guide provides steps for manual installation of Blazar using OpenStack
   Ansible. These instructions are valid for Ubuntu 18.04 All-in-one (AIO).

Install and bootstrap Ansible (master branch) as the root user:

.. code:: bash

   # git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
   # cd /opt/openstack-ansible

.. note::
   At the time of writing, work is still ongoing upstream in OpenStack.
   Therefore, it is recommended to set ANSIBLE_ROLE_FETCH_MODE to git-clone.

.. code:: bash

   # export ANSIBLE_ROLE_FETCH_MODE=git-clone
   # scripts/bootstrap-ansible.sh
   # scripts/bootstrap-aio.sh

Enable Blazar:

.. code:: bash

   # cp etc/openstack_deploy/conf.d/blazar.yml.aio /etc/openstack_deploy/conf.d/
   # cd /etc/openstack_deploy/conf.d
   # mv blazar.yml.aio blazar.yml

Run Ansible playbooks:

.. code:: bash

   # cd /opt/openstack-ansible/playbooks
   # openstack-ansible setup-hosts.yml
   # openstack-ansible setup-infrastructure.yaml
   # openstack-ansible setup-openstack.yml

Once the playbooks have successfully executed, it is possible to make some
modifications to the Blazar Ansible role in /etc/ansible/roles/os_blazar
and re-install the Blazar service by executing:

.. code:: bash

   # cd /opt/openstack-ansible/playbooks
   # openstack-ansible os-blazar-install.yml
