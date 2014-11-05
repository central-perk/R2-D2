// Generated by CoffeeScript 1.7.1
var async, config, dao, filePath, mongoose, path, utils, _;

path = require('path');

_ = require('lodash');

async = require('async');

mongoose = require('mongoose');

filePath = process.g.path;

config = process.g.config;

utils = process.g.utils;

dao = require(filePath.daos);

module.exports = {
  hasLogin: function(req, res, next) {
    if (!req.isAuthenticated()) {
      return res.error('用户未登录，重定向至登录页面');
    } else {
      return next();
    }
  }
};
