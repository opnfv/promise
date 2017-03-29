.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

Promise installation
====================

Install nodejs, npm and promise

.. code-block:: bash

    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm -g install npm@latest
    git clone https://gerrit.opnfv.org/gerrit/promise
    cd promise/source
    npm install

Please note that the last command 'npm install' will install all needed dependencies
for promise (including yangforge and mocha)

.. figure:: images/screenshot_promise_install.png
   :name: figure1
      :width: 90%


Validation
==========
Please perform the following preparation steps:

1. Set OpenStack environment parameters properly (e.g. source openrc admin demo
   in DevStack)
2. Create OpenStack tenant (e.g. promise) and tenant user (e.g. promiser)
3. Create a flavor in Nova with 1 vCPU and 512 MB RAM
4. Create a private network, subnet and router in Neutron
5. Create an image in Glance

Once done, the promise test script can be invoked as follows (as a single line
command):

.. code-block:: bash

   NODE_ENV=mytest \
   OS_TENANT_NAME=promise \
   OS_USERNAME=promiser \
   OS_PASSWORD=<user password from Step 2> \
   OS_TEST_FLAVOR=<flavor ID from Step 3> \
   OS_TEST_NETWORK=<network ID from Step 4> \
   OS_TEST_IMAGE=<image ID from Step 5> \
   npm run -s test -- --reporter json > promise-results.json

The results of the tests will be stored in the promise-results.json file.

The results can also be seen in the console ("npm run -s test")

.. figure:: images/screenshot_promise.png
   :name: figure2
   :width: 90%

All 33 tests passing?!
Congratulations, promise has been successfully installed and configured.
