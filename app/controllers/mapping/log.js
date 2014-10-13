// Generated by CoffeeScript 1.7.1
var FIELD_TYPE_MAP, LOGGER_DEFAULT_LEVEL, Schema, appCtrl, async, attrLegal, attrLowerCase, config, filePath, logDao, logModel, mongoose, utils, _;

async = require('async');

mongoose = require('mongoose');

_ = require('lodash');

Schema = mongoose.Schema;

logModel = mongoose.model('log');

config = process.g.config;

utils = process.g.utils;

filePath = process.g.path;

FIELD_TYPE_MAP = config.FIELD_TYPE_MAP;

LOGGER_DEFAULT_LEVEL = config.LOGGER.defaultLevel;

appCtrl = utils.getCtrl('app');

logDao = utils.getDao('log');

attrLegal = function(attrs) {
  var attrUnique, name, nameValid, uniqueNames;
  name = _.flatten(attrs, 'labelName');
  uniqueNames = _.uniq(name);
  attrUnique = name.length === uniqueNames.length;
  nameValid = true;
  _.each(attrs, function(attr) {
    if (attr.fieldName.slice(0, 1) === '_') {
      return nameValid = false;
    }
  });
  return attrUnique && nameValid;
};

attrLowerCase = function(attrs) {
  _.forEach(attrs, function(attr, index) {
    return attrs[index].fieldName = attr.fieldName.toLowerCase();
  });
  return attrs;
};

module.exports = {
  create: function(req, res) {
    var app, attrs, body, labelName, name;
    body = req.body;
    app = body.app;
    name = body.name;
    labelName = body.labelName;
    attrs = attrLowerCase(body.attrs);
    if (!attrLegal(attrs)) {
      return res.errorMsg('属性不能以下划线开头，且不能重复');
    } else {
      return async.waterfall([
        function(cb) {
          return appCtrl._getByID(app, function(err, app) {
            if (app) {
              return cb(null, null);
            } else {
              return cb(err || '应用未授权');
            }
          });
        }, function(result, cb) {
          return logDao.getOne({
            app: app,
            name: name
          }, function(err, log) {
            if (!log) {
              return cb(null, null);
            } else {
              return cb(err || '日志已经存在，不能重复创建');
            }
          });
        }, function(result, cb) {
          return logDao.create({
            app: app,
            name: name,
            labelName: labelName,
            attrs: attrs
          }, cb);
        }, function(result, cb) {
          return logDao.getOne({
            app: app,
            name: name
          }, function(err, log) {
            return module.exports['_register'](log, function(err) {
              return cb(err && '日志创建成功，mongo注册失败');
            });
          });
        }
      ], function(err) {
        if (!err) {
          return res.successMsg('日志创建成功');
        } else {
          console.log(err);
          return res.errorMsg(err);
        }
      });
    }
  },
  list: function(req, res) {
    var options, query;
    query = req.query;
    options = {};
    return logDao.list(query, options, function(err, logs) {
      if (!err) {
        return res.success(logs);
      } else {
        console.log(err);
        return res.errorMsg(err || '授权列表获取失败');
      }
    });
  },
  update: function(req, res) {
    var body, logID;
    logID = req.params.logID;
    body = req.body;
    delete body.app;
    delete body.name;
    delete body.ts;
    return logDao.updateByID(logID, body, function(err, data) {
      if (!err) {
        return res.successMsg('日志更新成功');
      } else {
        return res.errorMsg(err || '日志更新失败');
      }
    });
  },
  groupApp: function(req, res) {
    return async.auto({
      getApps: function(cb) {
        return logDao.Model.find({}, 'app').populate('app', 'name ts').exec(cb);
      },
      getLogs: function(cb) {
        return logDao.Model.aggregate([
          {
            $group: {
              _id: {
                app: '$app'
              },
              log: {
                $push: {
                  name: '$name',
                  labelName: '$labelName'
                }
              }
            }
          }
        ], cb);
      }
    }, function(err, results) {
      var apps;
      apps = _.groupBy(results.getApps, function(log) {
        return log.app._id;
      });
      _.forEach(results.getLogs, function(log) {
        var appID;
        appID = log._id.app;
        log.app = apps[appID][0].app;
        return delete log._id;
      });
      results.getLogs = _.sortBy(results.getLogs, function(log) {
        return log.app.ts;
      });
      return res.success(results.getLogs);
    });
  },
  _register: function(log, callback) {
    var appID, err, logAttrs, logName, loggerName, schema, schemaObj;
    schemaObj = {};
    appID = log.app;
    logName = log.name;
    logAttrs = log.attrs;
    loggerName = "" + appID + "." + logName;
    _.forEach(logAttrs, function(attr) {
      var fieldName, fieldType, labelName;
      fieldName = attr.fieldName;
      labelName = attr.labelName;
      fieldType = attr.fieldType;
      if (fieldType === 'Date') {
        return schemaObj[fieldName] = {
          type: Date,
          get: utils.dateTimeFormat
        };
      } else {
        return schemaObj[fieldName] = FIELD_TYPE_MAP[fieldType];
      }
    });
    schemaObj._ts = {
      type: Date,
      "default": Date.now,
      get: utils.dateTimeFormat
    };
    schemaObj._fileName = String;
    schemaObj._level = {
      type: Number,
      "default": LOGGER_DEFAULT_LEVEL
    };
    schema = new Schema(schemaObj);
    try {
      mongoose.model(loggerName, schema);
      process.emit('registerLogger', loggerName);
      return callback(null);
    } catch (_error) {
      err = _error;
      return callback(err);
    }
  },
  _registerAll: function() {
    return logDao.get({}, function(err, logs) {
      var count, logLength;
      logLength = logs.length;
      count = 0;
      return async.whilst(function() {
        return count < logLength;
      }, function(cb) {
        count++;
        return module.exports['_register'](logs[count - 1], cb);
      }, function(err, result) {
        if (err) {
          return console.log(err);
        }
      });
    });
  },
  _getOne: function(query, callback) {
    return logDao.getOne(query, callback);
  }
};

//# sourceMappingURL=log.map
