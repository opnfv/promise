#
# Author: Peter K. Lee (peter@corenova.com)
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
request = require 'superagent'

module.exports =
  'create-tenant':
    (input, output, done) ->
      # TODO - this requires OS-KSADM extension
