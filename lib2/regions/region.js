// Generated by CoffeeScript 1.4.0
(function() {
  var AMIs, Servers, async;

  async = require("async");

  Servers = require("./servers");

  AMIs = require("./amis");

  module.exports = (function() {

    function _Class(name, ec2) {
      this.name = name;
      this.ec2 = ec2;
      this.amis = new AMIs(this);
      this.servers = new Servers(this);
    }

    _Class.prototype.load = function(callback) {
      var _this = this;
      async.forEach([this.amis, this.servers], (function(loadable, next) {
        return loadable.load(next);
      }), callback);
      return this;
    };

    return _Class;

  })();

}).call(this);