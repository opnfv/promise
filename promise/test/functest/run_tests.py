#!/usr/bin/python
#
# Copyright (c) 2015 All rights reserved
# This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
import argparse
import json
import os
import re
import subprocess
import time

import functest.utils.functest_logger as ft_logger
import functest.utils.openstack_utils as os_utils
from functest.utils.constants import CONST

parser = argparse.ArgumentParser()

parser.add_argument("-d", "--debug", help="Debug mode", action="store_true")
parser.add_argument("-r", "--report",
                    help="Create json result file",
                    action="store_true")
args = parser.parse_args()


PROMISE_REPO_DIR = CONST.dir_repo_promise
RESULTS_DIR = CONST.dir_results

PROMISE_TENANT_NAME = CONST.promise_tenant_name
TENANT_DESCRIPTION = CONST.promise_tenant_description
PROMISE_USER_NAME = CONST.promise_user_name
PROMISE_USER_PWD = CONST.promise_user_pwd
PROMISE_IMAGE_NAME = CONST.promise_image_name
PROMISE_FLAVOR_NAME = CONST.promise_flavor_name
PROMISE_FLAVOR_VCPUS = CONST.promise_flavor_vcpus
PROMISE_FLAVOR_RAM = CONST.promise_flavor_ram
PROMISE_FLAVOR_DISK = CONST.promise_flavor_disk


GLANCE_IMAGE_FILENAME = CONST.openstack_image_file_name
GLANCE_IMAGE_FORMAT = CONST.openstack_image_disk_format
GLANCE_IMAGE_NAME = CONST.openstack_image_file_name
GLANCE_IMAGE_PATH = os.path.join(CONST.dir_functest_data,
                                 GLANCE_IMAGE_FILENAME)

PROMISE_NET_NAME = CONST.promise_network_name
PROMISE_SUBNET_NAME = CONST.promise_subnet_name
PROMISE_SUBNET_CIDR = CONST.promise_subnet_cidr
PROMISE_ROUTER_NAME = CONST.promise_router_name


""" logging configuration """
logger = ft_logger.Logger("promise").getLogger()


def main():
    change_keystone_version = False
    os_auth = os.environ["OS_AUTH_URL"]

    # check keystone version
    # if keystone v3, for keystone v2
    if os_utils.is_keystone_v3():
        os.environ["OS_IDENTITY_API_VERSION"] = "2"
        # the OS_AUTH_URL may have different format according to the installer
        # apex: OS_AUTH_URL=http://192.168.37.17:5000/v2.0
        # fuel: OS_AUTH_URL='http://192.168.0.2:5000/'
        #       OS_AUTH_URL='http://192.168.10.2:5000/v3
        match = re.findall(r'[0-9]+(?:\.[0-9]+){3}:[0-9]+',
                           os.environ["OS_AUTH_URL"])
        new_url = "http://" + match[0] + "/v2.0"

        os.environ["OS_AUTH_URL"] = new_url
        change_keystone_version = True
        logger.info("Force Keystone v2")

    creds = os_utils.get_credentials()

    try:
        logger.info("Env variables")
        logger.info("OS_AUTH_URL: %s" % os.environ["OS_AUTH_URL"])
        logger.info("OS_IDENTITY_API_VERSION: %s " %
                    os.environ["OS_IDENTITY_API_VERSION"])
    except KeyError:
        logger.error("Please set the OS environment variables")

    keystone_client = os_utils.get_keystone_client()

    user_id = os_utils.get_user_id(keystone_client, creds['username'])
    if user_id == '':
        logger.error("Error : Failed to get id of %s user" %
                     creds['username'])
        exit(-1)

    logger.info("Creating tenant '%s'..." % PROMISE_TENANT_NAME)
    tenant_id = os_utils.create_tenant(
        keystone_client, PROMISE_TENANT_NAME, TENANT_DESCRIPTION)
    if not tenant_id:
        logger.error("Error : Failed to create %s tenant"
                     % PROMISE_TENANT_NAME)
        exit(-1)
    logger.debug("Tenant '%s' created successfully." % PROMISE_TENANT_NAME)

    roles_name = ["admin", "Admin"]
    role_id = ''
    for role_name in roles_name:
        if role_id == '':
            role_id = os_utils.get_role_id(keystone_client, role_name)

    if role_id == '':
        logger.error("Error : Failed to get id for %s role" % role_name)
        exit(-1)

    logger.info("Adding role '%s' to tenant '%s'..."
                % (role_id, PROMISE_TENANT_NAME))
    if not os_utils.add_role_user(keystone_client, user_id,
                                  role_id, tenant_id):
        logger.error("Error : Failed to add %s on tenant %s" %
                     (creds['username'], PROMISE_TENANT_NAME))
        exit(-1)
    logger.debug("Role added successfully.")

    logger.info("Creating user '%s'..." % PROMISE_USER_NAME)
    user_id = os_utils.create_user(
        keystone_client, PROMISE_USER_NAME, PROMISE_USER_PWD, None, tenant_id)

    if not user_id:
        logger.error("Error : Failed to create %s user" % PROMISE_USER_NAME)
        exit(-1)
    logger.debug("User '%s' created successfully." % PROMISE_USER_NAME)

    neutron_client = os_utils.get_neutron_client()
    nova_client = os_utils.get_nova_client()
    glance_client = os_utils.get_glance_client()

    logger.info("Creating image '%s' from '%s'..." % (PROMISE_IMAGE_NAME,
                                                      GLANCE_IMAGE_PATH))

    logger.info("Upload some OS images if it doesn't exist")

    images = {"image_name": GLANCE_IMAGE_NAME, "image_url": GLANCE_IMAGE_PATH}
    for image_name, image_url in images.iteritems():
        image_id = os_utils.get_image_id(glance_client, image_name)

        if image_id == '':
            logger.info("%s image doesn't exist on glance repo" % image_name)
            logger.info("Try downloading this image and upload on glance !")
            image_id = os_utils.create_glance_image(
                glance_client, GLANCE_IMAGE_NAME, GLANCE_IMAGE_PATH)

        if image_id == '':
            logger.error("Failed to create the Glance image...")
            exit(-1)

    logger.debug("Image '%s' with ID '%s' created successfully."
                 % (PROMISE_IMAGE_NAME, image_id))
    flavor_id = os_utils.get_flavor_id(nova_client, PROMISE_FLAVOR_NAME)
    if flavor_id == '':
        logger.info("Creating flavor '%s'..." % PROMISE_FLAVOR_NAME)
        flavor_id = os_utils.create_flavor(nova_client,
                                           PROMISE_FLAVOR_NAME,
                                           PROMISE_FLAVOR_RAM,
                                           PROMISE_FLAVOR_DISK,
                                           PROMISE_FLAVOR_VCPUS)
        if not flavor_id:
            logger.error("Failed to create the Flavor...")
            exit(-1)
        logger.debug("Flavor '%s' with ID '%s' created successfully." %
                     (PROMISE_FLAVOR_NAME, flavor_id))
    else:
        logger.debug("Using existing flavor '%s' with ID '%s'..."
                     % (PROMISE_FLAVOR_NAME, flavor_id))

    network_dic = os_utils.create_network_full(neutron_client,
                                               PROMISE_NET_NAME,
                                               PROMISE_SUBNET_NAME,
                                               PROMISE_ROUTER_NAME,
                                               PROMISE_SUBNET_CIDR)
    if not network_dic:
        logger.error("Failed to create the private network...")
        exit(-1)

    logger.info("Exporting environment variables...")
    os.environ["NODE_ENV"] = "functest"
    os.environ["OS_PASSWORD"] = PROMISE_USER_PWD
    os.environ["OS_TEST_IMAGE"] = image_id
    os.environ["OS_TEST_FLAVOR"] = flavor_id
    os.environ["OS_TEST_NETWORK"] = network_dic["net_id"]
    os.environ["OS_TENANT_NAME"] = PROMISE_TENANT_NAME
    os.environ["OS_USERNAME"] = PROMISE_USER_NAME

    os.chdir(PROMISE_REPO_DIR + '/source/')
    results_file_name = os.path.join(RESULTS_DIR, 'promise-results.json')
    results_file = open(results_file_name, 'w+')
    cmd = 'npm run -s test -- --reporter json'

    logger.info("Running command: %s" % cmd)
    ret = subprocess.call(cmd, shell=True, stdout=results_file,
                          stderr=subprocess.STDOUT)
    results_file.close()

    if ret == 0:
        logger.info("The test succeeded.")
        # test_status = 'OK'
    else:
        logger.info("The command '%s' failed." % cmd)
        # test_status = "Failed"

    # Print output of file
    with open(results_file_name, 'r') as results_file:
        data = results_file.read()
        logger.debug("\n%s" % data)
        json_data = json.loads(data)

        suites = json_data["stats"]["suites"]
        tests = json_data["stats"]["tests"]
        passes = json_data["stats"]["passes"]
        pending = json_data["stats"]["pending"]
        failures = json_data["stats"]["failures"]
        start_time_json = json_data["stats"]["start"]
        end_time = json_data["stats"]["end"]
        duration = float(json_data["stats"]["duration"]) / float(1000)

    logger.info("\n"
                "****************************************\n"
                "          Promise test report\n\n"
                "****************************************\n"
                " Suites:  \t%s\n"
                " Tests:   \t%s\n"
                " Passes:  \t%s\n"
                " Pending: \t%s\n"
                " Failures:\t%s\n"
                " Start:   \t%s\n"
                " End:     \t%s\n"
                " Duration:\t%s\n"
                "****************************************\n\n"
                % (suites, tests, passes, pending, failures,
                   start_time_json, end_time, duration))
    end_time = time.time()

    # re set default keysone version to 3 if it has been changed for promise
    if change_keystone_version:
        os.environ["OS_IDENTITY_API_VERSION"] = "3"
        os.environ["OS_AUTH_URL"] = os_auth
        logger.info("Revert to Keystone v3")

    exit(0)


if __name__ == '__main__':
    main()
