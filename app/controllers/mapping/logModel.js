// Generated by CoffeeScript 1.7.1
var logModelDao;

logModelDao = require(process.g.daoPath)['logModel'];

module.exports = {
  create: function(req, res) {
    return logModelDao.create({
      type: req.body.type,
      attributes: req.body.attributes
    }, function(err, raw) {
      if (!err) {
        return res.requestSucceed('日志模型创建成功');
      } else {
        return res.requestError('日志模型创建失败');
      }
    });
  }
};
