// Generated by CoffeeScript 1.7.1
var auth, ctrl, logModel, path, utils;

path = require('path');

utils = process.g.utils;

ctrl = utils.getCtrl('index');

auth = utils.getCtrl('auth');

logModel = utils.getCtrl('logModel');

module.exports = function(app, mw) {
  app.post('/auth', auth.create);
  app.get('/auth', auth.list);
  app.post('/logmodel', logModel.create);
  app.put('/logmodel', logModel.update);
  app.get('/logmodel', logModel.list);
  app.get('/logmodel/attrvalue', logModel.listAttrValue);
  app.get('/', mw.distribute);
  return app.get('/login', ctrl.list('login'));
};
