gumbo = require "gumbo"
_ = require "underscore"
waitForCollectionSync = require "../../utils/waitForCollectionSync"

module.exports = class extends gumbo.Collection

  ###
  ###

  constructor: (@region, @options) ->
    @ec2 = region.ec2

    if not options.modelClass
      throw new Error "modelClass must be present"

    super [], _.bind(@_createModel, @)
    @sync = @synchronizer { uniqueKey: "_id", load: _.bind(@_load, @), timeout: 1000 * 60 }

  ###
  ###

  load: (callback) ->

    if not @_initialLoad
      @_initialLoad = true
      return @sync.start callback

    @sync.load callback


  ###
  ###

  syncAndFindOne: (options, callback) ->
    waitForCollectionSync options, @, true, _.bind(@sync.load, @sync), callback


  ###
  ###

  _createModel: (collection, item) ->
    new @options.modelClass collection, @region, @_transformItem item

  ###
  ###

  _load: (onLoad) ->
    throw new Error "must be overridden"


  ###
  ###

  _transformItem: (item) -> 
    item.region = @region.get "name"
    item


  ###
  ###

  _load: () ->