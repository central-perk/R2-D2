logModelDao = require(process.g.daoPath)['logModel']

module.exports = {
	create: (req, res)->
		# 已经存在就不用创建
		logModelDao.create({
			type: req.body.type,
			attributes: req.body.attributes
		}, (err, raw)->
			if !err
				res.requestSucceed('日志模型创建成功')
			else
				res.requestError('日志模型创建失败')
		)
}