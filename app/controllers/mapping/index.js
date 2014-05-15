// Generated by CoffeeScript 1.7.1
var fs, logger, modelsPath, path, _;

path = require('path');

fs = require('fs');

_ = require('lodash');

logger = require(path.join(__dirname, 'log'));

modelsPath = path.join(process.g.modelsPath, 'mapping');

module.exports = {
  openLogin: function(req, res) {
    var log;
    log = new logger('login');
    log(req.query);
    return res.send('ok');
  }
};
