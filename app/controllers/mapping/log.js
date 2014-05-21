// Generated by CoffeeScript 1.7.1
var config, fLogSize, fNewestLog, fWriteFile, fs, logsPath, path, utils;

path = require('path');

fs = require('fs-extra');

utils = process.g.utils;

config = process.g.config;

logsPath = process.g.logsPath;

fNewestLog = function(logName) {
  var aLogFiles, sNewestLog;
  sNewestLog = '';
  aLogFiles = fs.readdirSync(logsPath);
  aLogFiles = _.sortBy(aLogFiles, function(str) {
    var num;
    num = Number(str.split('.')[2]);
    return num;
  });
  _.each(aLogFiles, function(sFileName) {
    var rPat;
    rPat = new RegExp(logName);
    if (rPat.test(sFileName)) {
      return sNewestLog = sFileName;
    }
  });
  if (Number(sNewestLog.split('.')[1]) === Number(utils.getTime())) {
    return sNewestLog;
  } else {
    return false;
  }
};

fLogSize = function(sNewestLogPath) {
  var nSize;
  nSize = fs.readFileSync(sNewestLogPath, 'utf8').length;
  return config.LOG_MAX_SIZE > nSize;
};

fWriteFile = function(sNewestLogPath) {
  return function(message, cb) {
    message = JSON.stringify(message, null, 0) + '\n';
    return fs.writeFile(sNewestLogPath, message, {
      encoding: 'utf8',
      flag: 'a'
    }, cb);
  };
};

module.exports = function(logName) {
  var aNewestLogName, bLogExists, bLogSizeOK, sNewestLogName, sNewestLogPath;
  sNewestLogName = fNewestLog(logName);
  bLogExists = Boolean(sNewestLogName);
  if (bLogExists) {
    sNewestLogPath = path.join(logsPath, sNewestLogName);
    bLogSizeOK = fLogSize(sNewestLogPath);
    if (bLogSizeOK) {
      return fWriteFile(sNewestLogPath);
    } else {
      aNewestLogName = sNewestLogName.split('.');
      aNewestLogName[2] = Number(aNewestLogName[2]) + 1;
      sNewestLogName = aNewestLogName.join('.');
      sNewestLogPath = path.join(logsPath, sNewestLogName);
      return fWriteFile(sNewestLogPath);
    }
  } else {
    sNewestLogName = logName + '.' + utils.getTime() + '.0.log';
    sNewestLogPath = path.join(logsPath, sNewestLogName);
    return fWriteFile(sNewestLogPath);
  }
};
