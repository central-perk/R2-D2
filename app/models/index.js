// Generated by CoffeeScript 1.7.1
var fs, modelsPath, mongoose, path, _;

fs = require('fs');

path = require('path');

_ = require('lodash');

mongoose = require('mongoose');

modelsPath = path.join(__dirname, 'mapping');

_.each(fs.readdirSync(modelsPath), function(file, index) {
  var modelName;
  require(path.join(modelsPath, file));
  modelName = file.replace('.js', '');
  module.exports[modelName] = mongoose.model(modelName);
});
