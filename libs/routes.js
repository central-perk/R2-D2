// Generated by CoffeeScript 1.7.1
var Ctrl, fs, mw, path, routesPath, _;

fs = require('fs');

path = require('path');

_ = require('lodash');

routesPath = process.g.routesPath;

Ctrl = require(process.g.controllersPath);

mw = require(path.join(routesPath, 'middlewares'));

module.exports = function(app) {
  return _.each(fs.readdirSync(routesPath), function(file, index) {
    var controller, ctrlName;
    if (~file.indexOf('.js')) {
      ctrlName = file.replace('.js', '');
      if (Ctrl[ctrlName]) {
        controller = Ctrl[ctrlName];
        return require(path.join(routesPath, file))(app, mw, controller);
      } else {
        return require(path.join(routesPath, file))(app, mw);
      }
    }
  });
};
