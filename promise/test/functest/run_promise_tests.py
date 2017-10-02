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
import logging
import os
import re
import subprocess
import sys
import time

import functest.utils.openstack_utils as os_utils
from functest.utils.constants import CONST

parser = argparse.ArgumentParser()

parser.add_argument("-d", "--debug", help="Debug mode", action="store_true")
parser.add_argument("-r", "--report",
                    help="Create json result file",
                    action="store_true")
args = parser.parse_args()


PROMISE_REPO_DIR = '/src/promise'
RESULTS_DIR = CONST.dir_results

PROMISE_TENANT_NAME = CONST.promise_tenant_name
PROMISE_PROJECT_NAME = CONST.promise_tenant_name
PROMISE_PROJECT_DESCRIPTION = CONST.promise_tenant_description
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
GLANCE_IMAGE_PATH = os.path.join(CONST.dir_functest_images,
                                 GLANCE_IMAGE_FILENAME)

PROMISE_NET_NAME = CONST.promise_network_name
PROMISE_SUBNET_NAME = CONST.promise_subnet_name
PROMISE_SUBNET_CIDR = CONST.promise_subnet_cidr
PROMISE_ROUTER_NAME = CONST.promise_router_name


""" logging configuration """
logger = logging.getLogger('promise')


def main():
    return_code = -1
    os_auth = os.environ["OS_AUTH_URL"]

    creds = os_utils.get_credentials()

    try:
        logger.info("Env variables")
        logger.info("OS_AUTH_URL: %s" % os.environ["OS_AUTH_URL"])
        logger.info("OS_IDENTITY_API_VERSION: %s " %
                    os.environ["OS_IDENTITY_API_VERSION"])
        logger.info("OS_USER_DOMAIN_NAME: %s" %
                    os.environ["OS_USER_DOMAIN_NAME"])
        logger.info("OS_PROJECT_DOMAIN_NAME: %s" %
                    os.environ["OS_PROJECT_DOMAIN_NAME"])
    except KeyError:
        logger.error("Please set the OS environment variables")

    keystone_client = os_utils.get_keystone_client()

    logger.info("Creating project '%s'..." % PROMISE_PROJECT_NAME)
    project_id = os_utils.create_tenant(
        keystone_client, PROMISE_PROJECT_NAME, PROMISE_PROJECT_DESCRIPTION)
    if not project_id:
        logger.error("Error : Failed to create %s project"
                     % PROMISE_PROJECT_NAME)
        return return_code
    logger.debug("Project '%s' created successfully." % PROMISE_PROJECT_NAME)

    roles_name = ["_member_", "Member"]
    role_id = ''
    for role_name in roles_name:
        if role_id == '':
            role_id = os_utils.get_role_id(keystone_client, role_name)

    if role_id == '':
        logger.error("Error : Failed to get id for %s role" % role_name)
        return return_code

    domain_id = ''
    domain_id = os_utils.get_domain_id(keystone_client, 
                                       os.environ["OS_USER_DOMAIN_NAME"])
    if domain_id == '':
        logger.error("Error: Failed to get id for %s domain" % 
                     os.environ["OS_USER_DOMAIN_NAME"])
        return return_code

    logger.info("Creating user '%s'..." % PROMISE_USER_NAME)
    try:
         user = keystone_client.users.create(name=PROMISE_USER_NAME,
                                             domain=domain_id,
                                             password=PROMISE_USER_PWD)
    except Exception as e:
        logger.error("Error : Failed to create %s user" % PROMISE_USER_NAME)
        return return_code
    logger.debug("User '%s' created successfully." % PROMISE_USER_NAME)

    try:
         keystone_client.roles.grant(role=role_id, user=user.id,
                                     project=project_id)
    except Exception as e:
        logger.error("Error: Failed to grant member role on project %s" %
                     project_id)
        return return_code

    nova_client = os_utils.get_nova_client()
    glance_client = os_utils.get_glance_client()

    logger.info("Creating image '%s' from '%s'..." % (PROMISE_IMAGE_NAME,
                                                      GLANCE_IMAGE_PATH))

    logger.info("Upload some OS images if it doesn't exist")

    image_id = os_utils.get_image_id(glance_client, GLANCE_IMAGE_NAME)

    if image_id == '':
        logger.info("%s image doesn't exist on glance repo" % GLANCE_IMAGE_NAME)
        logger.info("Try downloading this image and upload on glance !")
        image_id = os_utils.create_glance_image(
            glance_client, GLANCE_IMAGE_NAME, GLANCE_IMAGE_PATH)

    if image_id == '':
        logger.error("Failed to create the Glance image...")
        return return_code

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
            return return_code
        logger.debug("Flavor '%s' with ID '%s' created successfully." %
                     (PROMISE_FLAVOR_NAME, flavor_id))
    else:
        logger.debug("Using existing flavor '%s' with ID '%s'..."
                     % (PROMISE_FLAVOR_NAME, flavor_id))

    network_dic = os_utils.create_shared_network_full(PROMISE_NET_NAME,
                                                      PROMISE_SUBNET_NAME,
                                                      PROMISE_ROUTER_NAME,
                                                      PROMISE_SUBNET_CIDR)
    if not network_dic:
        logger.error("Failed to create the private network...")
        return return_code

    logger.info("Exporting environment variables...")
    os.environ["NODE_ENV"] = "functest"
    os.environ["OS_PASSWORD"] = PROMISE_USER_PWD
    os.environ["OS_TEST_IMAGE"] = image_id
    os.environ["OS_TEST_FLAVOR"] = flavor_id
    os.environ["OS_TEST_NETWORK"] = network_dic["net_id"]
    os.environ["OS_PROJECT_NAME"] = PROMISE_PROJECT_NAME
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
        return_code = 0
    else:
        logger.info("The command '%s' failed." % cmd)

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

    return return_code


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    sys.exit(main())
