
_              = require "underscore"
Tags           = require "../tags"
gumbo          = require "gumbo"
comerr         = require "comerr"
copyTags       = require "../../utils/copyTags"
BaseModel      = require "../base/model"
findOneOrErr   = require "../../utils/findOneOrErr"
tagsToObject   = require "../../utils/tagsToObject"
objectToTags   = require "../../utils/objectToTags"
createInstance = require "../../utils/createInstance"

###

Server States:

+--------+---------------+
|  Code  |     State     |
+--------+---------------+
|   0    |    pending    | 
|  16    |    running    |
|  32    | shutting-down | 
|  48    |  terminated   |
|  64    |   stopping    | 
|  80    |   stopped     |
+--------+---------------

###

module.exports = class extends BaseModel

  ###
  ###

  constructor: (collection, region, item) ->
    super collection, region, item
    @tags = new Tags @

  ###
    Function: start
      Starts the server. Note: if the server is stopping, ectwo will wait
      until the server has stopped completely before running the "start" command

    Parameters:
      callback - Called once the srver has properly started
  ###

  start: (callback = (()->)) -> 
    @_runCommand "running", _.bind(this.start2, this, callback), callback

  ###
    secondary start function that bypasses the "running" check
  ###

  start2: (callback) ->

      state = @get "state"

      # stopped? Perfect - this is the state we want to be in
      # TODO: handle the callback result
      if /stopped/.test state
        #@_ec2.call "StartInstances", { "InstanceId.1": @get "_id" }, callback
        @_callAndWaitUntilState "StartInstances", "running", callback
      else

      # server is shutting down
      if /shutting-down|stopping/.test state
        @_waitUntilState "stopped|terminated", () => @start callback
      else

      # server is still initializing, it'll startup in a bit
      # TODO - pending might throw an error
      if /pending/.test state
        @_waitUntilState "running", callback

  ###
    Function: stop
      Stops the server. 

    Parameters:
      callback - Called once the server has stopped
  ###


  stop: (callback = (()->)) ->
    @logger.info "stop"
    @_runCommand "stopped", _.bind(this._stop2, this, callback), callback

  ###
  ###

  reboot: (callback) ->
    @logger.info "reboot"
    @stop @_o.e(callback).s () =>
      @start callback

  ###
  ###

  getAddress: (callback) ->
    findOneOrErr @region.addresses, { instanceId: @get("_id") }, callback

  ###
  ###

  _stop2: (callback) ->

    state = @get "state"


    if /running/.test state
      # @_ec2.call "StopInstances", { "InstanceId.1": @get "_id" }, callback
      @_callAndWaitUntilState "StopInstances", "stopped", callback
    else
    if /stopping|shutting-down/.test state
      @_waitUntilState "stopped|terminated", () => @stop callback
    else
    if /pending/.test state
      @_waitUntilState "running", () => @stop callback

  ###
    Function: terminate

    Terminates the EC2 instance

    Parameters:
  ###

  _destroy: (callback) ->
    @_runCommand "terminated", _.bind(this.terminate2, this, callback), callback

  ###
  ###

  terminate2: (callback) ->
    @_callAndWaitUntilState "TerminateInstances", "terminated", callback


  ###
    Function: getAMI

    Fetches the AMI of this instance

    Parameters:
  ###

  getImage: (callback) ->
    @region.images.syncAndFindOne { instanceId: @get("_id") }, callback

  ###
    Function: createAMI

    Parameters:
      callback - called once the AMI is created

    Returns:
      The AMI
  ###

  createImage: (options, callback) -> 

    @logger.info "create image"

    self = @
    @stop () =>
      options = {
        "InstanceId": @get("_id"),
        "Name": options.name or String(Date.now())
      }
      @_ec2.call "CreateImage", options, @_o.s (result) =>
        @logger.info "created image _id=#{result.imageId}"
        @region.images.syncAndFindOne { _id: result.imageId }, @_o.s (image) =>
          copyTags @, image, { createdAt: Date.now() }, @_o.s () =>
             callback null, image
  ###
    Function: clone

      Clones the server based on the AMI id, *and* the instance flavor (c1.medium perhaps)

    Parameters:

    Returns:
      The new EC2 instance
  ###

  clone: (callback) -> 
    self = @

    ## TODO - sync & find one
    createInstance @region, {
      imageId: @get("imageId"),
      flavor: @get("type")
    }, result

  ###
    Function: 

    Parameters:
  ###

  _runCommand: (expectedState, runCommand, callback) ->

    @_skipIfState expectedState, callback, () =>
      state = @get "state"


      if /terminated/.test state
        callback new comerr.NotFound "The instance has been terminated."
      else
      if not /stopping|stopped|shutting-down|running|pending/.test state
        callback new comerr.UnknownError "An unrecognized instance state was returned."
      else
        runCommand()

  ###
  ###

  _callAndWaitUntilState: (command, state, callback) ->

    fn = null

    if typeof command isnt "function"
      fn = (callback) =>
        @_ec2.call command, {"InstanceId.1": @get "_id" }, callback
    else 
      fn = command

    fn @_o.e(callback).s () =>
      @_waitUntilState state, callback

  ###
    Waits until the server reaches this particular state
    Parameters:
  ###

  _waitUntilState: (state, callback) ->
    @waitUntilSync { state: state }, callback

  ###
  ###

  _skipIfState: (state, end, callback) ->
    @_skipIfSynced { state: state }, end, callback











