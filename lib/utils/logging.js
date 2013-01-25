// Generated by CoffeeScript 1.4.0
(function() {

  global.ectwo_log = {};

  if (process.env.ECTWO_LOGGING || true) {
    global.ectwo_log = console;
  } else {
    ["log", "warn", "error", "notice"].forEach(function(method) {
      return global.ectwo_log[method] = (function() {});
    });
  }

}).call(this);