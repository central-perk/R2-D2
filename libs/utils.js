// Generated by CoffeeScript 1.7.1
var fs, moment, path, _;

path = require('path');

fs = require('fs');

_ = require('lodash');

moment = require('moment');

module.exports = {
  getTime: function(date) {
    var config, time;
    config = process.g.config;
    time = moment(date).utc().zone(-8).format("YYYYMMDDHHmm");
    return time = time - time % config.LOG_INTERVAL;
  },
  formatTime: function(date) {
    var time;
    return time = moment(date).utc().zone(-8).format("YYYY-MM-DD HH:mm:ss");
  },
  setG: function(rootPath) {
    var appPath, configPath, libs, libsPath, logsPath, publicPath;
    configPath = path.join(rootPath, 'config');
    appPath = path.join(rootPath, 'app');
    libsPath = path.join(rootPath, 'libs');
    logsPath = path.join(rootPath, 'logs');
    publicPath = path.join(rootPath, 'public');
    process.g = {
      config: require(configPath),
      rootPath: rootPath,
      configPath: configPath,
      appPath: appPath,
      libsPath: libsPath,
      logsPath: logsPath,
      publicPath: publicPath
    };
    _.each(fs.readdirSync(appPath), function(dir, index) {
      var dirPath;
      dirPath = path.join(appPath, dir);
      return process.g[dir + 'Path'] = dirPath;
    });
    libs = {};
    _.each(fs.readdirSync(libsPath), function(file, index) {
      var fileName;
      if (~file.indexOf('.js')) {
        fileName = file.replace('.js', '');
        return libs[fileName] = path.join(libsPath, file);
      }
    });
    process.g.libs = libs;
    return process.g.utils = require(libs.utils);
  },
  pagination: function(page, perPage, count) {
    var clas, curpage, p, pages, pagination, _i;
    pagination = {};
    pages = Math.ceil(count / perPage);
    curpage = page;
    clas = page === (curpage ? 'active' : 'no');
    if (count <= perPage) {
      return null;
    }
    pagination.left = (page - 1) > 1 ? page - 1 : 1;
    pagination.content = [];
    for (p = _i = 0; 0 <= pages ? _i <= pages : _i >= pages; p = 0 <= pages ? ++_i : --_i) {
      curpage = p;
      clas = page === (curpage ? 'active' : 'no');
      if (page === curpage) {
        pagination.active = curpage;
      }
      pagination.content.push({
        pclass: clas,
        curpage: curpage,
        ptext: curpage
      });
    }
    pagination.right = (parseInt(page) + 1) >= pages ? pages : parseInt(page) + 1;
    return pagination;
  }
};
