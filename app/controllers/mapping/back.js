// Generated by CoffeeScript 1.7.1
var config, eventRestart, filePath, isPro, utils, _;

_ = require('lodash');

config = process.g.config;

utils = process.g.utils;

filePath = process.g.path;

eventRestart = null;

isPro = process.env.NODE_ENV === 'pro';

module.exports = {
  index: function(req, res) {
    console.log({
      isPro: isPro
    });
    return res.render('index', {
      isPro: isPro
    });
  },
  restart: function(req, res) {
    eventRestart = setTimeout(function() {
      return utils.restart();
    }, 10000);
    return res.successMsg('服务将在10秒后重启');
  },
  cancelRestart: function(req, res) {
    clearTimeout(eventRestart);
    return res.successMsg('重启服务已被取消');
  }
};

//# sourceMappingURL=back.map
