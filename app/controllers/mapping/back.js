// Generated by CoffeeScript 1.7.1
var PERPAGE, async, auth, config, fListAM, fs, logModel, mongoose, path, utils, viewsPath, _;

path = require('path');

fs = require('fs-extra');

_ = require('lodash');

async = require('async');

mongoose = require('mongoose');

config = process.g.config;

utils = process.g.utils;

auth = utils.getCtrl('auth');

logModel = utils.getCtrl('logModel');

viewsPath = process.g.viewsPath;

PERPAGE = config.PERPAGE;

fListAM = function(callback) {
  return async.auto({
    aAuth: function(cb) {
      return auth._listAll(cb);
    },
    aLogModels: function(cb) {
      return logModel._listAll(cb);
    }
  }, callback);
};

module.exports = {
  index: function(req, res) {
    var nav;
    nav = config.BACK.nav;
    return fListAM(function(err, oListAM) {
      var aAuth, aDynamicNav, aLogModels;
      aDynamicNav = [];
      if (!err) {
        aAuth = oListAM.aAuth;
        aLogModels = oListAM.aLogModels;
        _.each(aAuth, function(oAuth) {
          var temp;
          temp = {
            title: oAuth.appName,
            href: oAuth.appID
          };
          if (aLogModels.length) {
            temp.sub = [];
          }
          _.each(aLogModels, function(oLogModel) {
            if (oLogModel.appID === oAuth.appID) {
              return temp.sub.push({
                title: oLogModel.cname,
                href: "" + oAuth.appID + "." + oLogModel.name
              });
            }
          });
          return aDynamicNav.push(temp);
        });
      }
      return res.render('back/index.html', {
        nav: nav,
        dnav: aDynamicNav
      });
    });
  },
  getContent: function(req, res) {
    var Model, aLogModelsList, e, module, nPage, sAppID, sLogName;
    module = req.params['module'];
    switch (module) {
      case 'auth':
        return auth._listAll(function(err, aAuthList) {
          return res.render('back/auth.html', {
            aAuthList: aAuthList
          });
        });
      case 'logmodel':
        aLogModelsList = [];
        return fListAM(function(err, oListAM) {
          var aAttrValue, aAuth, aLogModels;
          if (!err) {
            aAuth = oListAM.aAuth;
            aLogModels = oListAM.aLogModels;
            _.each(aAuth, function(oAuth) {
              return _.each(aLogModels, function(oLogModel) {
                if (oAuth.appID === oLogModel.appID) {
                  return aLogModelsList.push({
                    appName: oAuth.appName,
                    appID: oAuth.appID,
                    token: oAuth.token,
                    name: oLogModel.name,
                    cname: oLogModel.cname,
                    ts: oLogModel.ts
                  });
                }
              });
            });
          }
          aAttrValue = logModel._listAttrValue();
          return res.render('back/logmodel.html', {
            aLogModelsList: aLogModelsList,
            aAuth: aAuth,
            aLogModels: aLogModels,
            aAttrValue: aAttrValue
          });
        });
      default:
        sAppID = module.split('.')[0];
        sLogName = module.split('.')[1];
        nPage = (req.param('page') > 0 ? req.param('page') : 1) - 1;
        try {
          Model = mongoose.model(module);
          return async.auto({
            getOneAuth: function(cb) {
              return auth._getOne({
                appID: sAppID
              }, cb);
            },
            getOneModel: function(cb) {
              return logModel._getOne({
                appID: sAppID,
                name: sLogName
              }, cb);
            },
            getLogs: function(cb) {
              return Model.find({}, '-__v -_id -fileName').sort({
                ts: -1
              }).skip(PERPAGE * nPage).limit(PERPAGE).exec(cb);
            },
            pageAmount: function(cb) {
              return Model.count({}, function(err, num) {
                var pages;
                pages = Math.floor(num / PERPAGE) + 1;
                return cb(err, pages);
              });
            }
          }, function(err, results) {
            var aLogAttr, aLogs, nPageAmount, nTs, oAuth, oLogModel, sLogCname, sToken, temp, url, _aLogs;
            if (!err) {
              oAuth = results.getOneAuth;
              oLogModel = results.getOneModel;
              nPageAmount = results.pageAmount;
              sLogCname = results.getOneModel.cname;
              _aLogs = results.getLogs;
              aLogAttr = _.reduce(oLogModel.attr, function(arr, attr) {
                arr.push({
                  name: attr.name,
                  cname: attr.cname
                });
                return arr;
              }, []);
              aLogAttr.push({
                name: '_ts',
                cname: '时间'
              });
              aLogAttr.push({
                name: '_level',
                cname: '等级'
              });
              sToken = oAuth.token;
              nTs = oLogModel.ts;
              url = "/upload/app/" + sAppID + "/logname/" + sLogName + "/token/" + sToken;
              if (_aLogs.length) {
                aLogs = [];
                _.each(_aLogs, function(oLog) {
                  var temp;
                  temp = {};
                  _.each(aLogAttr, function(oAttr) {
                    var name;
                    name = oAttr.name;
                    return temp[name] = oLog[name] || '';
                  });
                  return aLogs.push(temp);
                });
                temp = {
                  url: url,
                  appID: sAppID,
                  name: sLogName,
                  cname: sLogCname,
                  ts: nTs,
                  logs: aLogs,
                  logAttr: aLogAttr,
                  pageAmount: nPageAmount,
                  page: nPage + 1
                };
              } else {
                temp = {
                  url: url,
                  appID: sAppID,
                  name: sLogName,
                  ts: nTs
                };
              }
              return res.render('back/apps.html', temp);
            } else {
              return res.render('授权信息出错了!');
            }
          });
        } catch (_error) {
          e = _error;
          console.log(e);
          return res.send('日志模型不存在!');
        }
    }
  }
};
