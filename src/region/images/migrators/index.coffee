EventEmitter = require("events").EventEmitter

###
###

module.exports = class extends EventEmitter

  ###
  ###

  constructor: (@image, @migrators) ->

    @_images = []
    @_progresses = []
    @logger = @image.logger.child "migrator"

    for migrator,i in @migrators
      @_progresses.push 0
      @_watchMigrator migrator, i


  ###
  ###

  _watchMigrator: (migrator, i) ->

    migrator.on "progress", (progress) =>
      @_progresses[i] = progress

      sum = 0

      for p in @_progresses
        sum += p

      @_totalProgress = Math.round sum / @_progresses.length

      @logger.info "progress=#{@_totalProgress}%"

      @emit "progress", @_totalProgress


    migrator.on "complete", (image) =>
      @_images.push(image)


      @logger.info "migrated to #{image.get("region")}, #{@_images.length}/#{@_progresses.length} complete"

      if @_images.length is @_progresses.length
        @logger.info "complete"
        @emit "complete", @_images
