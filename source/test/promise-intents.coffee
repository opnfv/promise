config = require 'config'
assert = require 'assert'
forge  = require 'yangforge'
app = forge.load '!yaml ../promise.yaml', async: false, pkgdir: __dirname

# this is javascript promise framework and not related to opnfv-promise
promise = require 'promise'

if process.env.DEBUG
  debug = console.log
else
  debug = ->

# in the future with YF 0.12.x
# app = forge.load('..').build('test')
# app.set config
# app.use 'proxy', target: x.x.x.x:5050, interface: 'restjson'

describe "promise", ->
  before ->
    # ensure we have valid OpenStack environment to test against
    try
      config.get 'openstack.auth.endpoint'
    catch e
      throw new Error "missing OpenStack environmental variables"


  # below 'provider' is used across test suites
  provider = undefined

  # Test Scenario 00 (FUTURE)
  # describe "prepare OpenStack for testing", ->
  #   before (done) ->
  #     # ensure we have valid OpenStack environment to test against
  #     try
  #       config.get 'openstack.auth.url'
  #     catch e
  #       throw new Error "missing OpenStack environmental variables"

  #     os = forge.load '!yaml ../openstack.yaml', async: false, pkgdir: __dirname
  #     app.attach 'openstack', os.access 'openstack'
  #     app.set config

  #   describe "authenticate", ->
  #     it "should retrieve available service catalog", (done) ->
  #       app.access('openstack').invoke 'authenticate'
  #       .then (res) ->

  #         done()
  #       .catch (err) -> done err

  #   describe "create-tenant", ->
  #     # create a new tenant for testing purposes

  #   describe "upload-image", ->
  #     # upload a new test image



  # Test Scenario 01
  describe "register OpenStack into resource pool", ->
    pool = undefined

    # TC-01
    describe "add-provider", ->
      it "should add a new OpenStack provider without error", (done) ->
        @timeout 5000

        auth = config.get 'openstack.auth'
        auth['provider-type'] = 'openstack'

        app.access('opnfv-promise').invoke 'add-provider', auth
        .then (res) ->
          res.get('result').should.equal 'ok'
          provider = id: res.get('provider-id')
          # HACK - we delay by a second to allow time for discovering capacity and flavors
          setTimeout done, 1000
        .catch (err) -> done err

      it "should update promise.providers with a new entry", ->
        app.get('opnfv-promise.promise.providers').should.have.length(1)

      it "should contain a new ResourceProvider record in the store", ->
        assert provider?.id?, "unable to check without ID"
        provider = app.access('opnfv-promise').find('ResourceProvider', provider.id)
        assert provider?

    # TC-02
    describe "increase-capacity", ->
      it "should add more capacity to the reservation service without error", (done) ->
        app.access('opnfv-promise').invoke 'increase-capacity',
          source: provider
          capacity:
            cores: 20
            ram: 51200
            instances: 10
            addresses: 10
        .then (res) ->
          res.get('result').should.equal 'ok'
          pool = id: res.get('pool-id')
          done()
        .catch (err) -> done err

      it "should update promise.pools with a new entry", ->
        app.get('opnfv-promise.promise.pools').should.have.length(1)

      it "should contain a ResourcePool record in the store", ->
        assert pool?.id?, "unable to check without ID"
        pool = app.access('opnfv-promise').find('ResourcePool', pool.id)
        assert pool?

    # TC-03
    describe "query-capacity", ->
      it "should report total collections and utilizations", (done) ->
        app.access('opnfv-promise').invoke 'query-capacity',
          capacity: 'total'
        .then (res) ->
          res.get('collections').should.be.Array
          res.get('collections').length.should.be.above(0)
          res.get('utilization').should.be.Array
          res.get('utilization').length.should.be.above(0)
          done()
        .catch (err) -> done err

      it "should contain newly added capacity pool", (done) ->
        app.access('opnfv-promise').invoke 'query-capacity',
          capacity: 'total'
        .then (res) ->
          res.get('collections').should.containEql "ResourcePool:#{pool.id}"
          done()
        .catch (err) -> done err

  # Test Scenario 02
  describe "allocation without reservation", ->

    # TC-04
    describe "create-instance", ->
      allocation = undefined
      instance_id = undefined

      before ->
        # XXX - need to determine image and flavor to use in the given provider for this test
        assert provider?,
          "unable to execute without registered 'provider'"

      it "should create a new server in target provider without error", (done) ->
        @timeout 5000
        test = config.get 'openstack.test'
        app.access('opnfv-promise').invoke 'create-instance',
          'provider-id': provider.id
          name: 'promise-test-no-reservation'
          image:   test.image
          flavor:  test.flavor
          networks: [ test.network ]
        .then (res) ->
          debug res.get()
          res.get('result').should.equal 'ok'
          instance_id = res.get('instance-id')
          done()
        .catch (err) -> done err

      it "should update promise.allocations with a new entry", ->
        app.get('opnfv-promise.promise.allocations').length.should.be.above(0)

      it "should contain a new ResourceAllocation record in the store", ->
        assert instance_id?, "unable to check without ID"
        allocation = app.access('opnfv-promise').find('ResourceAllocation', instance_id)
        assert allocation?

      it "should reference the created server ID from the provider", ->
        assert allocation?, "unable to check without record"
        allocation.get('instance-ref').should.have.property('provider')
        allocation.get('instance-ref').should.have.property('server')

      it "should have low priority state", ->
        assert allocation?, "unable to check without record"
        allocation.get('priority').should.equal 'low'

  # Test Scenario 03
  describe "allocation using reservation for immediate use", ->
    reservation = undefined

    # TC-05
    describe "create-reservation", ->
      it "should create reservation record (no start/end) without error", (done) ->
        app.access('opnfv-promise').invoke 'create-reservation',
          capacity:
            cores: 5
            ram: 25600
            addresses: 3
            instances: 3
        .then (res) ->
          res.get('result').should.equal 'ok'
          reservation = id: res.get('reservation-id')
          done()
        .catch (err) -> done err

      it "should update promise.reservations with a new entry", ->
        app.get('opnfv-promise.promise.reservations').length.should.be.above(0)

      it "should contain a new ResourceReservation record in the store", ->
        assert reservation?.id?, "unable to check without ID"
        reservation = app.access('opnfv-promise').find('ResourceReservation', reservation.id)
        assert reservation?

    # TC-06
    describe "create-instance", ->
      allocation = undefined

      before ->
        assert provider?,
          "unable to execute without registered 'provider'"
        assert reservation?,
          "unable to execute without valid reservation record"

      it "should create a new server in target provider (with reservation) without error", (done) ->
        @timeout 5000
        test = config.get 'openstack.test'
        app.access('opnfv-promise').invoke 'create-instance',
          'provider-id': provider.id
          name: 'promise-test-reservation'
          image:  test.image
          flavor: test.flavor
          networks: [ test.network ]
          'reservation-id': reservation.id
        .then (res) ->
          debug res.get()
          res.get('result').should.equal 'ok'
          allocation = id: res.get('instance-id')
          done()
        .catch (err) -> done err

      it "should contain a new ResourceAllocation record in the store", ->
        assert allocation?.id?, "unable to check without ID"
        allocation = app.access('opnfv-promise').find('ResourceAllocation', allocation.id)
        assert allocation?

      it "should be referenced in the reservation record", ->
        assert reservation? and allocation?, "unable to check without records"
        reservation.get('allocations').should.containEql allocation.id

      it "should have high priority state", ->
        assert allocation?, "unable to check without record"
        allocation.get('priority').should.equal 'high'

  # Test Scenario 04
  describe "reservation for future use", ->
    reservation = undefined
    start = new Date
    end   = new Date
    # 7 days in the future
    start.setTime (start.getTime() + 7*60*60*1000)
    # 8 days in the future
    end.setTime (end.getTime() + 8*60*60*1000)

    # TC-07
    describe "create-reservation", ->
      it "should create reservation record (for future) without error", (done) ->
        app.access('opnfv-promise').invoke 'create-reservation',
          start: start.toJSON()
          end: end.toJSON()
          capacity:
            cores: 1
            ram: 12800
            addresses: 1
            instances: 1
        .then (res) ->
          res.get('result').should.equal 'ok'
          reservation = id: res.get('reservation-id')
          done()
        .catch (err) -> done err

      it "should update promise.reservations with a new entry", ->
        app.get('opnfv-promise.promise.reservations').length.should.be.above(0)

      it "should contain a new ResourceReservation record in the store", ->
        assert reservation?.id?, "unable to check without ID"
        reservation = app.access('opnfv-promise').find('ResourceReservation', reservation.id)
        assert reservation?

    # TC-08
    describe "query-reservation", ->
      it "should contain newly created future reservation", (done) ->
        app.access('opnfv-promise').invoke 'query-reservation',
          window:
            start: start.toJSON()
            end: end.toJSON()
        .then (res) ->
          res.get('reservations').should.containEql reservation.id
          done()
        .catch (err) -> done err

    # TC-09
    describe "update-reservation", ->
      it "should modify existing reservation without error", (done) ->
        app.access('opnfv-promise').invoke 'update-reservation',
          'reservation-id': reservation.id
          capacity:
            cores: 3
            ram: 12800
            addresses: 2
            instances: 2
        .then (res) ->
          res.get('result').should.equal 'ok'
          done()
        .catch (err) -> done err

    # TC-10
    describe "cancel-reservation", ->
      it "should modify existing reservation without error", (done) ->
        app.access('opnfv-promise').invoke 'cancel-reservation',
          'reservation-id': reservation.id
        .then (res) ->
          res.get('result').should.equal 'ok'
          done()
        .catch (err) -> done err

      it "should no longer contain record of the deleted reservation", ->
        assert reservation?.id?, "unable to check without ID"
        reservation = app.access('opnfv-promise').find('ResourceReservation', reservation.id)
        assert not reservation?

  # Test Scenario 05
  describe "capacity planning", ->

    # TC-11
    describe "decrease-capacity", ->
      start = new Date
      end   = new Date
      # 30 days in the future
      start.setTime (start.getTime() + 30*60*60*1000)
      # 45 days in the future
      end.setTime (end.getTime() + 45*60*60*1000)

      it "should decrease available capacity from a provider in the future", (done) ->
        app.access('opnfv-promise').invoke 'decrease-capacity',
          source: provider
          capacity:
            cores: 5
            ram: 17920
            instances: 5
          start: start.toJSON()
          end: end.toJSON()
        .then (res) ->
          res.get('result').should.equal 'ok'
          done()
        .catch (err) -> done err

    # TC-12
    describe "increase-capacity", ->
      start = new Date
      end   = new Date
      # 14 days in the future
      start.setTime (start.getTime() + 14*60*60*1000)
      # 21 days in the future
      end.setTime (end.getTime() + 21*60*60*1000)

      it "should increase available capacity from a provider in the future", (done) ->
        app.access('opnfv-promise').invoke 'decrease-capacity',
          source: provider
          capacity:
            cores: 1
            ram: 3584
            instances: 1
          start: start.toJSON()
          end: end.toJSON()
        .then (res) ->
          res.get('result').should.equal 'ok'
          done()
        .catch (err) -> done err

    # TC-13 (Should improve this TC)
    describe "query-capacity", ->
      it "should report available collections and utilizations", (done) ->
        app.access('opnfv-promise').invoke 'query-capacity',
          capacity: 'available'
        .then (res) ->
          res.get('collections').should.be.Array
          res.get('collections').length.should.be.above(0)
          res.get('utilization').should.be.Array
          res.get('utilization').length.should.be.above(0)
          done()
        .catch (err) -> done err

  # Test Scenario 06
  describe "reservation with conflict", ->
    # TC-14
    describe "create-reservation", ->
      it "should fail to create immediate reservation record with proper error", (done) ->
        app.access('opnfv-promise').invoke 'create-reservation',
          capacity:
            cores: 5
            ram: 17920
            instances: 10
        .then (res) ->
          res.get('result').should.equal 'conflict'
          done()
        .catch (err) -> done err

      it "should fail to create future reservation record with proper error", (done) ->
        start = new Date
        # 30 days in the future
        start.setTime (start.getTime() + 30*60*60*1000)

        app.access('opnfv-promise').invoke 'create-reservation',
          capacity:
            cores: 5
            ram: 17920
            instances: 10
          start: start.toJSON()
        .then (res) ->
          res.get('result').should.equal 'conflict'
          done()
        .catch (err) -> done err

  # Test Scenario 07
  describe "cleanup test allocations", ->
    allocations = undefined
    before ->
      allocations = app.get('opnfv-promise.promise.allocations')
      debug provider.get()
      debug allocations
      allocations.length.should.be.above(0)

    describe "destroy-instance", ->
      it "should successfully destroy all allocations", (done) ->
        @timeout 5000
        promises = allocations.map (x) ->
          app.access('opnfv-promise').invoke 'destroy-instance',
            'instance-id': x.id
        promise.all promises
        .then (res) ->
          res.forEach (x) ->
            debug x.get()
            x.get('result').should.equal 'ok'
          done()
        .catch (err) -> done err
