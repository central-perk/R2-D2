// Generated by CoffeeScript 1.7.1
var AUTH_STATUS, authDao, config, createAppID, createToken, crypto, fMd5, _;

crypto = require('crypto');

_ = require('lodash');

config = process.g.config;

AUTH_STATUS = config.STATUS.AUTH;

authDao = require(process.g.daoPath).auth;

fMd5 = function(text) {
  return crypto.createHash('md5').update(text).digest('hex');
};

createToken = function(appName) {
  var nRandom, text;
  nRandom = Math.random();
  text = appName + nRandom;
  return fMd5(text);
};

createAppID = function(appName) {
  return createToken(appName).slice(0, 6);
};

module.exports = {
  create: function(req, res) {
    var appName;
    appName = req.body.appName;
    return authDao.getOne({
      appName: appName
    }, function(err, auth) {
      var appID, token;
      if (!auth) {
        appID = createAppID(appName);
        token = createToken(appName);
        return authDao.getOne({
          appID: appID
        }, function(err, auth) {
          if (!auth) {
            return authDao.create({
              appName: appName,
              appID: appID,
              token: token
            }, function(err, raw) {
              if (!err) {
                return res.requestSucceed('应用授权成功');
              } else {
                return res.requestError('应用授权失败');
              }
            });
          } else {
            return module.exports['create'](req, res);
          }
        });
      } else {
        appID = auth.appID;
        token = auth.token;
        return res.requestError('应用已授权');
      }
    });
  },
  list: function(req, res) {
    var criteria;
    criteria = {
      query: {
        status: AUTH_STATUS.enable
      }
    };
    return authDao.list(criteria, {
      ts: -1
    }, function(err, auths) {
      var aAuth;
      if (!err) {
        aAuth = [];
        _.each(auths, function(auth) {
          return aAuth.push({
            appName: auth.appName,
            appID: auth.appID,
            token: auth.token,
            ts: auth.ts,
            status: auth.status
          });
        });
        return res.requestSucceed(aAuth);
      } else {
        return res.requestError('授权列表获取失败');
      }
    });
  },
  _get: function(query, callback) {
    return authDao.get(query, callback);
  },
  _getOne: function(query, callback) {
    return authDao.getOne(query, callback);
  },
  _listAll: function(callback) {
    return authDao.listAll(function(err, aAuth) {
      var temp;
      temp = [];
      if (!err) {
        _.each(aAuth, function(oAuth) {
          return temp.push({
            appName: oAuth.appName,
            appID: oAuth.appID,
            token: oAuth.token,
            ts: oAuth.ts,
            status: oAuth.status
          });
        });
      }
      return callback(err, temp);
    });
  },
  _checkAuth: function(query, callback) {
    var appID, token;
    appID = query.appID;
    token = query.token;
    return authDao.getOne({
      appID: appID,
      token: token
    }, function(err, oAuth) {
      var bAuthorized;
      bAuthorized = oAuth ? true : false;
      return callback(err, bAuthorized);
    });
  }
};
