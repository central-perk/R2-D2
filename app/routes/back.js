// Generated by CoffeeScript 1.7.1
var back, utils;

utils = process.g.utils;

back = utils.getCtrl('back');

module.exports = function(app, mw) {
  app.get('/back', back.index);
  return app.get('/api/:module', back.getContent);
};
