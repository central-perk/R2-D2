// Generated by CoffeeScript 1.7.1
var CronJob, config, path, request, storage;

path = require('path');

storage = require(path.join(process.g.controllersPath, 'mapping', 'storage'));

CronJob = require('cron').CronJob;

request = require('request');

config = process.g.config;

module.exports = function(logPath) {};
