// Generated by CoffeeScript 1.7.1
(function() {
  var LOGGERFILE_STATUS, PERPAGE, STORAGE_MAXLINES, appCtrl, async, config, filePath, fs, json2db, kueCtrl, log2json, logCtrl, loggerFileCtrl, loggersPath, mongoose, utils, _;

  _ = require('lodash');

  async = require('async');

  mongoose = require('mongoose');

  fs = require('fs-extra');

  config = process.g.config;

  utils = process.g.utils;

  filePath = process.g.path;

  LOGGERFILE_STATUS = config.LOGGERFILE.status;

  STORAGE_MAXLINES = config.STORAGE.maxLines;

  PERPAGE = config.APP.PAGE.perPage;

  loggersPath = path.join(filePath.root, 'loggers');

  appCtrl = utils.getCtrl('app');

  logCtrl = utils.getCtrl('log');

  kueCtrl = utils.getCtrl('kue');

  loggerFileCtrl = utils.getCtrl('loggerFile');

  log2json = function(data) {
    var loggers;
    loggers = data.split('\n').slice(0, -1);
    _.forEach(loggers, function(logger, index) {
      return loggers[index] = JSON.parse(logger);
    });
    return loggers;
  };

  json2db = function(Model, loggers, callback) {
    var loggersLength;
    loggersLength = loggers.length;
    return Model.create(loggers.slice(0, STORAGE_MAXLINES), function(err, raw) {
      if (!err) {
        if (STORAGE_MAXLINES >= loggersLength) {
          return loggerFileCtrl.updateStatus({
            _fileName: loggers[0]._fileName,
            status: LOGGERFILE_STATUS.storaged
          }, callback);
        } else {
          return json2db(Model, loggers.slice(STORAGE_MAXLINES), callback);
        }
      } else {
        return callback(err);
      }
    });
  };

  module.exports = {
    create: function(req, res) {
      return res.success({
        code: 200
      });
    },
    list: function(req, res) {
      var Model, appID, e, loggerName, name, page, query;
      query = req.query;
      appID = query.app;
      name = query.name;
      page = Number(query.page) - 1 || 0;
      loggerName = "" + appID + "." + name;
      try {
        Model = mongoose.model(loggerName);
        return async.auto({
          getList: function(cb) {
            return Model.find({}).sort({
              _ts: -1
            }).limit(PERPAGE).skip(PERPAGE * page).exec(cb);
          }
        }, function(err, results) {
          var loggers, paging;
          if (!err) {
            loggers = results.getList;
            paging = {
              curPage: page + 1,
              noNext: loggers.length < PERPAGE
            };
            return res.success({
              paging: paging,
              loggers: loggers
            });
          } else {
            console.log(err);
            return res.errorMsg('授权列表获取失败');
          }
        });
      } catch (_error) {
        e = _error;
        return res.errorMsg('日志列表获取失败');
      }
    },
    _storage: function(loggerFile, callback) {
      var Model, app, logName, loggerFileName, loggerFilePath, loggerFileStatus, loggerName;
      app = loggerFile.app;
      loggerName = loggerFile.name;
      logName = loggerName.split('.')[1];
      loggerFileName = loggerFile._fileName;
      loggerFilePath = path.join(loggersPath, loggerFileName);
      loggerFileStatus = loggerFile.status;
      Model = mongoose.model(loggerName);
      return async.waterfall([
        function(cb) {
          if (loggerFileStatus === LOGGERFILE_STATUS.unstorage) {
            return cb(null, 0);
          } else {
            return Model.count({
              _fileName: loggerFileName
            }, cb);
          }
        }, function(line, cb) {
          return fs.readFile(loggerFilePath, 'utf-8', function(err, loggers) {
            if (!err) {
              loggers = log2json(loggers);
              loggers = loggers.slice(Number(line));
              return loggerFileCtrl.updateStatus(loggerFile, function(err) {
                if (err) {
                  console.log(err);
                }
                if (!err) {
                  return json2db(Model, loggers, cb);
                } else {
                  return cb(err);
                }
              });
            } else {
              return cb(err);
            }
          });
        }
      ], callback);
    }
  };

}).call(this);
