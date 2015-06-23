var mongodbBackuper, CONFIG_TIME, CronJob, DB, after5s, async, config, d, fs, hour, jobBackupDB, jobCleanLogFile, loggerFileCtrl, minute, moment, path, second, utils;

path = require('path');

fs = require('fs-extra');

CronJob = require('cron').CronJob;

async = require('async');

moment = require('moment');

config = process.g.config;

utils = process.g.utils;

DB = config.APP.DB;

CONFIG_TIME = process.g.config.TIME;

mongodbBackuper = require('mongodb-backuper');

loggerFileCtrl = utils.getCtrl('loggerFile');

d = moment().add(5, 'seconds');

hour = d.hours();

minute = d.minutes();

second = d.seconds();

after5s = "" + second + " " + minute + " " + hour + " * * *";

jobBackupDB = new CronJob(CONFIG_TIME.midnight, function() {
  var dbBackupPath;
  dbBackupPath = path.join(process.g.rootPath, '..', 'logger_backup', 'db');
  fs.ensureDirSync(dbBackupPath);

  return mongodbBackuper.init({
    path: dbBackupPath,
    host: DB.host + ':' + DB.port,
    name: DB.name + '_' + process.env.NODE_ENV
  });
}, null, true, 'Asia/Shanghai');

jobCleanLogFile = new CronJob(config.TIME.sunday, function() {
  return loggerFileCtrl.clean();
}, null, true, 'Asia/Shanghai');
