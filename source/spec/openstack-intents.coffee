request = require 'superagent'

module.exports =
  'create-tenant':
    (input, output, done) ->
      # TODO - this requires OS-KSADM extension
