// Generated by CoffeeScript 1.4.0
(function() {
  var outcome, stepc;

  stepc = require("stepc");

  outcome = require("outcome");

  module.exports = function(region, options, callback) {
    var newInstanceId, o;
    ectwo_log.log("%s: create server", region.name);
    o = outcome.e(callback);
    newInstanceId = null;
    return stepc.async(function() {
      return this._ec2.call("RunInstances", {
        "ImageId": options.imageId,
        "MinCount": options.count || 1,
        "MaxCount": options.count || 1,
        "InstanceType": options.flavor || "m1.small"
      }, this);
    }, o.s(function(result) {
      newInstanceId = result.instancesSet.item.instanceId;
      return region.instances.load(this);
    }), o.s(function() {
      return region.servers.findOne({
        instanceId: newInstanceId
      }).exec(this);
    }), callback);
  };

}).call(this);