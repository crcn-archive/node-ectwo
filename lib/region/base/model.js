// Generated by CoffeeScript 1.4.0
(function() {
  var gumbo,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  gumbo = require("gumbo");

  module.exports = (function(_super) {

    __extends(_Class, _super);

    /*
        Function: 
    
        Parameters:
    */


    function _Class(collection, region, item) {
      this.region = region;
      this._ec2 = region.ec2;
      _Class.__super__.constructor.call(this, collection, item);
    }

    /*
    */


    _Class.prototype.reload = function(callback) {
      return this._sync(callback);
    };

    /*
        Function: 
    
        Parameters:
    */


    _Class.prototype._sync = function(callback) {
      return this.collection.sync.loadOne(this.get("_id"), callback);
    };

    return _Class;

  })(gumbo.BaseModel);

}).call(this);