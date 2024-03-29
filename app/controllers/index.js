// Generated by CoffeeScript 1.8.0
var config, ctrlsPath, daos, filePath, fs, modelsPath, path, routesPath, utils, wm, _;

path = require('path');

fs = require('fs-extra');

_ = require('lodash');

filePath = process.g.path;

config = process.g.config;

utils = process.g.utils;

ctrlsPath = path.join(__dirname, 'mapping');

modelsPath = path.join(filePath.models, 'mapping');

routesPath = path.join(filePath.routes, 'mapping');

daos = require(filePath.daos);

wm = require(path.join(filePath.routes, 'middlewares'));

_.forEach(fs.readdirSync(ctrlsPath), function(ctrlFileName, index) {
  var ctrl, ctrlDao, ctrlFilePath, ctrlName;
  if (~ctrlFileName.indexOf('.js')) {
    ctrlName = ctrlFileName.replace('.js', '');
    ctrlFilePath = path.join(ctrlsPath, ctrlFileName);
    ctrl = require(ctrlFilePath);
    ctrlDao = _.clone(daos[ctrlName]) || {};
    ctrl = _.merge(ctrlDao, ctrl);
    return module.exports[ctrlName] = ctrl;
  }
});
