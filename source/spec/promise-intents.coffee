#
# Author: Peter K. Lee (peter@corenova.com)
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
#
module.exports =
  'create-reservation':
    (input, output, done) ->
      # 1. create the reservation record (empty)
      reservation = @create 'ResourceReservation'
      reservations = @access 'promise.reservations'

      # 2. update the record with requested input
      reservation.invoke 'update', input.get()
      .then (res) ->
        # 3. save the record and add to list
        res.save()
        .then ->
          reservations.push res
          output.set result: 'ok', message: 'reservation request accepted'
          output.set 'reservation-id', res.id
          done()
        .catch (err) ->
          output.set result: 'error', message: err
          done()
      .catch (err) ->
        output.set result: 'conflict', message: err
        done()

  'query-reservation':
    (input, output, done) ->
      query = input.get()
      query.capacity = 'reserved'
      @invoke 'query-capacity', query
      .then (res) ->
        output.set 'reservations', res.get 'collections'
        output.set 'utilization', res.get 'utilization'
        done()
      .catch (e) -> done e

  'update-reservation':
    (input, output, done) ->
      # TODO: we shouldn't need this... need to check why leaf mandatory: true not being enforced
      unless (input.get 'reservation-id')?
        output.set result: 'error', message: "must provide 'reservation-id' parameter"
        return done()

      # 1. find the reservation
      reservation = @find 'ResourceReservation', input.get 'reservation-id'
      unless reservation?
        output.set result: 'error', message: 'no reservation found for specified identifier'
        return done()

      # 2. update the record with requested input
      reservation.invoke 'update', input.get()
      .then (res) ->
        # 3. save the updated record
        res.save()
        .then ->
          output.set result: 'ok', message: 'reservation update successful'
          done()
        .catch (err) ->
          output.set result: 'error', message: err
          done()
      .catch (err) ->
        output.set result: 'conflict', message: err
        done()

  'cancel-reservation':
    (input, output, done) ->
      # 1. find the reservation
      reservation = @find 'ResourceReservation', input.get 'reservation-id'
      unless reservation?
        output.set result: 'error', message: 'no reservation found for specified identifier'
        return done()

      # 2. destroy all traces of this reservation
      reservation.destroy()
      .then =>
        (@access 'promise.reservations').remove reservation.id
        output.set 'result', 'ok'
        output.set 'message', 'reservation canceled'
        done()
      .catch (e) ->
        output.set 'result', 'error'
        output.set 'message', e
        done()

  'query-capacity':
    (input, output, done) ->
      # 1. we gather up all collections that match the specified window
      window = input.get 'window'
      metric = input.get 'capacity'

      collections = switch metric
        when 'total'     then [ 'ResourcePool' ]
        when 'reserved'  then [ 'ResourceReservation' ]
        when 'usage'     then [ 'ResourceAllocation' ]
        when 'available' then [ 'ResourcePool', 'ResourceReservation', 'ResourceAllocation' ]

      matches = collections.reduce ((a, name) =>
        res = @find name,
          start: (value) -> (not window.end?)   or (new Date value) <= (new Date window.end)
          end:   (value) -> (not window.start?) or (new Date value) >= (new Date window.start)
          enabled: true
        a.concat res...
      ), []

      if window.scope is 'exclusive'
        # yes, we CAN query filter in one shot above but this makes logic cleaner...
        matches = matches.where
          start: (value) -> (not window.start?) or (new Date value) >= (new Date window.start)
          end:   (value) -> (not window.end?) or (new Date value) <= (new Date window.end)

      # exclude any identifiers specified
      matches = matches.without id: (input.get 'without')

      if metric is 'available'
        # excludes allocations with reservation property set (to prevent double count)
        matches = matches.without reservation: (v) -> v?

      output.set 'collections', matches
      unless (input.get 'show-utilization') is true
        return done()

      # 2. we calculate the deltas based on start/end times of each match item
      deltas = matches.reduce ((a, entry) ->
        b = entry.get()
        b.end ?= 'infiniteT'
        [ skey, ekey ] = [ (b.start.split 'T')[0], (b.end.split 'T')[0] ]
        a[skey] ?= count: 0, capacity: {}
        a[ekey] ?= count: 0, capacity: {}
        a[skey].count += 1
        a[ekey].count -= 1

        for k, v of b.capacity when v?
          a[skey].capacity[k] ?= 0
          a[ekey].capacity[k] ?= 0
          if entry.name is 'ResourcePool'
            a[skey].capacity[k] += v
            a[ekey].capacity[k] -= v
          else
            a[skey].capacity[k] -= v
            a[ekey].capacity[k] += v
        return a
      ), {}

      # 3. we then sort the timestamps and aggregate the deltas
      last = count: 0, capacity: {}
      usages = for timestamp in Object.keys(deltas).sort() when timestamp isnt 'infinite'
        entry = deltas[timestamp]
        entry.timestamp = (new Date timestamp).toJSON()
        entry.count += last.count
        for k, v of entry.capacity
          entry.capacity[k] += (last.capacity[k] ? 0)
        last = entry
        entry

      output.set 'utilization', usages
      done()

  'increase-capacity':
    (input, output, done) ->
      pool = @create 'ResourcePool', input.get()
      pool.save()
      .then (res) =>
        (@access 'promise.pools').push res
        output.set result: 'ok', message: 'capacity increase successful'
        output.set 'pool-id', res.id
        done()
      .catch (e) ->
        output.set result: 'error', message: e
        done()

  'decrease-capacity':
    (input, output, done) ->
      request = input.get()
      for k, v of request.capacity
        request.capacity[k] = -v
      pool = @create 'ResourcePool', request
      pool.save()
      .then (res) =>
        (@access 'promise.pools').push res
        output.set result: 'ok', message: 'capacity decrease successful'
        output.set 'pool-id', res.id
        done()
      .catch (e) ->
        output.set result: 'error', message: e
        done()

  # TEMPORARY (should go into VIM-specific module)
  'create-instance':
    (input, output, done) ->
      pid = input.get 'provider-id'
      if pid?
        provider = @find 'ResourceProvider', pid
        unless provider?
          output.set result: 'error', message: "no matching provider found for specified identifier: #{pid}"
          return done()
      else
        provider = (@find 'ResourceProvider')[0]
        unless provider?
          output.set result: 'error', message: "no available provider found for create-instance"
          return done()

      # calculate required capacity based on 'flavor' and other params
      flavor = provider.access "services.compute.flavors.#{input.get 'flavor'}"
      unless flavor?
        output.set result: 'error', message: "no such flavor found for specified identifier: #{pid}"
        return done()

      required =
        instances: 1
        cores:     flavor.get 'vcpus'
        ram:       flavor.get 'ram'
        gigabytes: flavor.get 'disk'

      rid = input.get 'reservation-id'
      if rid?
        reservation = @find 'ResourceReservation', rid
        unless reservation?
          output.set result: 'error', message: 'no valid reservation found for specified identifier'
          return done()
        unless (reservation.get 'active') is true
          output.set result: 'error', message: "reservation is currently not active"
          return done()
        available = reservation.get 'remaining'
      else
        available = @get 'promise.capacity.available'

      # TODO: need to verify whether 'provider' associated with this 'reservation'

      for k, v of required when v? and !!v
        unless available[k] >= v
          output.set result: 'conflict', message: "required #{k}=#{v} exceeds available #{available[k]}"
          return done()

      @create 'ResourceAllocation',
        reservation: rid
        capacity: required
      .save()
      .then (instance) =>
        url = provider.get 'services.compute.endpoint'
        payload =
          server:
            name: input.get 'name'
            imageRef: input.get 'image'
            flavorRef: input.get 'flavor'
        networks = (input.get 'networks').filter (x) -> x? and !!x
        if networks.length > 0
          payload.server.networks = networks.map (x) -> uuid: x

        request = @parent.require 'superagent'
        request
          .post "#{url}/servers"
          .send payload
          .set 'X-Auth-Token', provider.get 'token'
          .set 'Accept', 'application/json'
          .end (err, res) =>
            if err? or !res.ok
              instance.destroy()
              #console.error err
              return done res.error
            #console.log JSON.stringify res.body, null, 2
            instance.set 'instance-ref',
              provider: provider
              server: res.body.server.id
            (@access 'promise.allocations').push instance
            output.set result: 'ok', message: 'create-instance request accepted'
            output.set 'instance-id', instance.id
            done()
         return instance
      .catch (err) ->
        output.set result: 'error', mesage: err
        done()

  'destroy-instance':
    (input, output, done) ->
      # 1. find the instance
      instance = @find 'ResourceAllocation', input.get 'instance-id'
      unless instance?
        output.set result: 'error', message: 'no allocation found for specified identifier'
        return done()

      # 2. destroy all traces of this instance
      instance.destroy()
      .then =>
        # always remove internally
        (@access 'promise.allocations').remove instance.id
        ref = instance.get 'instance-ref'
        provider = (@access "promise.providers.#{ref.provider}")
        url = provider.get 'services.compute.endpoint'
        request = @parent.require 'superagent'
        request
          .delete "#{url}/servers/#{ref.server}"
          .set 'X-Auth-Token', provider.get 'token'
          .set 'Accept', 'application/json'
          .end (err, res) =>
            if err? or !res.ok
              console.error err
              return done res.error
            output.set 'result', 'ok'
            output.set 'message', 'instance destroyed and resource released back to pool'
            done()
        return instance
      .catch (e) ->
        output.set 'result', 'error'
        output.set 'message', e
        done()

  # TEMPORARY (should go into VIM-specific module)
  'add-provider':
    (input, output, done) ->
      app = @parent
      request = app.require 'superagent'

      payload = switch input.get 'provider-type'
        when 'openstack'
          auth:
            tenantId: input.get 'tenant.id'
            tenantName: input.get 'tenant.name'
            passwordCredentials: input.get 'username', 'password'

      unless payload?
        return done 'Sorry, only openstack supported at this time'

      url = input.get 'endpoint'
      switch input.get 'strategy'
        when 'keystone', 'oauth'
          url += '/tokens' unless /\/tokens$/.test url

      providers = @access 'promise.providers'
      request
        .post url
        .send payload
        .set 'Accept', 'application/json'
        .end (err, res) =>
          if err? or !res.ok then return done res.error
          #console.log JSON.stringify res.body, null, 2
          access = res.body.access
          provider = @create 'ResourceProvider',
            token: access?.token?.id
            name: access?.token?.tenant?.name
          provider.invoke 'update', access.serviceCatalog
          .then (res) ->
            res.save()
            .then ->
              providers.push res
              output.set 'result', 'ok'
              output.set 'provider-id', res.id
              done()
            .catch (err) ->
              output.set 'error', message: err
              done()
          .catch (err) ->
            output.set 'error', message: err
            done()

      # @using 'mano', ->
      #   @invoke 'add-provider', (input.get 'endpoint', 'region', 'username', 'password')
      #   .then (res) =>
      #     (@access 'promise.providers').push res
      #     output.set 'result', 'ok'
      #     output.set 'provider-id', res.id
      #     done()
