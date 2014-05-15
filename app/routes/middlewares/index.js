// Generated by CoffeeScript 1.7.1
var ctrl, path;

path = require('path');

ctrl = require(path.join(process.g.controllersPath, 'mapping', 'index'));

module.exports = {
  distribute: function(req, res, next) {
    var timestamp, type;
    type = req.query._type;
    timestamp = req.query.timestamp;
    if (!type) {
      return res.requestError('缺少type');
    } else if (!timestamp) {
      return res.requestError('缺少timestamp');
    } else {
      if (ctrl[type]) {
        delete req.query._type;
        return ctrl[type](req, res);
      } else {
        return res.requestError('不存在该type');
      }
    }
  }
};
