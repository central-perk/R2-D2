// Generated by CoffeeScript 1.7.1
var aDataModels, config, jobs, kue, logModel, logger, storage, utils;

kue = require('kue');

jobs = kue.createQueue();

utils = process.g.utils;

config = process.g.config;

logger = utils.getCtrl('log');

logModel = utils.getCtrl('logModel');

storage = utils.getCtrl('storage');

aDataModels = _.keys(require('mongoose').models);

logModel.registerAll(function(err, aLogModels) {
  return _.each(aLogModels, function(oLogModel) {
    return module.exports['processLog'](oLogModel);
  });
});

jobs.process('storage', config.STORAGE.maxProcess, function(job, done) {
  var oLogFile;
  oLogFile = job.data.oLogFile;
  return storage.store(oLogFile, function(err) {
    if (!err) {
      console.log('数据入库成功');
      return done();
    }
  });
});

module.exports = {
  enqueueLog: function(oLogTemp) {
    var appID, oLog, sLogModelName, sLogType;
    appID = oLogTemp.appID;
    sLogType = oLogTemp.type;
    sLogModelName = "" + appID + "." + sLogType;
    oLog = oLogTemp.log;
    return jobs.create(sLogModelName, {
      log: oLog
    }).attempts(3).save();
  },
  processLog: function(oLogModel) {
    var appID, sLogModelName, sLogType;
    appID = oLogModel.appID;
    sLogType = oLogModel.type;
    sLogModelName = "" + appID + "." + sLogType;
    return jobs.process(sLogModelName, 1, function(job, done) {
      var oLog;
      sLogModelName = job.type;
      oLog = job.data.log;
      return logger(sLogModelName, function(err, fWriteLog) {
        return fWriteLog(oLog, function(err) {
          if (!err) {
            return done();
          }
        });
      });
    });
  },
  enqueueStorage: function(oLogFile) {
    return jobs.create('storage', {
      oLogFile: oLogFile
    }).attempts(3).save();
  }
};
