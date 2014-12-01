// Generated by CoffeeScript 1.7.1
var STORAGE_MAXPROCESS, config, filePath, jobs, kue, logCtrl, loggerCtrl, loggerFileCtrl, processLogger, utils, _;

kue = require('kue');

jobs = kue.createQueue();

_ = require('lodash');

config = process.g.config;

utils = process.g.utils;

filePath = process.g.path;

STORAGE_MAXPROCESS = config.STORAGE.maxProcess;

logCtrl = utils.getCtrl('log');

loggerCtrl = utils.getCtrl('logger');

loggerFileCtrl = utils.getCtrl('loggerFile');

processLogger = function(loggerName) {
  return jobs.process(loggerName, 1, function(job, done) {
    var logger;
    loggerName = job.type;
    logger = job.data.logger;
    return loggerFileCtrl.write(loggerName, function(err, writeFile) {
      return writeFile(logger, function(err) {
        if (err) {
          console.log(err);
        }
        return done();
      });
    });
  });
};

jobs.process('storage', 1, function(job, done) {
  var loggerFile;
  loggerFile = job.data.loggerFile;
  return loggerCtrl._storage(loggerFile, function(err) {
    return done();
  });
});

process.on('registerLogger', function(loggerName) {
  return processLogger(loggerName);
});

process.on('enqueueLogger', function(loggerTmp) {
  return module.exports['enqueueLogger'](loggerTmp);
});

process.on('enqueueStorage', function(loggerFile) {
  return module.exports['enqueueStorage'](loggerFile);
});

module.exports = {
  enqueueLogger: function(loggerTmp) {
    var appID, logName, logger, loggerName;
    appID = loggerTmp.appID;
    logName = loggerTmp.logName;
    loggerName = loggerTmp.loggerName;
    logger = loggerTmp.logger;
    return jobs.create(loggerName, {
      logger: logger
    }).attempts(3).save();
  },
  enqueueStorage: function(loggerFile) {
    return jobs.create('storage', {
      loggerFile: loggerFile
    }).attempts(3).save();
  }
};

//# sourceMappingURL=kue.map
