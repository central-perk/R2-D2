path = require('path')
async = require('async')
utils = process.g.utils
ctrl = utils.getCtrl('index')
auth = utils.getCtrl('auth')
kue  = utils.getCtrl('kue')
logModel = utils.getCtrl('logModel')
aAuth = {}


fEnqueue = (req, res)->
	sLogType = req.query.type
	appID = req.query.appID
	delete req.query.type
	delete req.query.appID
	delete req.query.token
	oLogTemp = {
		type: sLogType,
		appID,
		log: req.query
	}
	kue.enqueueLog(oLogTemp)
	res.requestSucceed('数据提交成功')

module.exports = {
	distribute: (req, res, next)->
		sLogType = req.query.type
		appID = req.query.appID
		token = req.query.token
		ts = req.query.ts

		sLogModelName = "#{appID}.#{sLogType}"
		if !sLogType
			res.requestError('缺少type')
		else if !ts
			res.requestError('缺少ts')
		else if !appID
			res.requestError('缺少appID')
		else if !token
			res.requestError('缺少token')
		else
			# 授权已经被缓存
			if aAuth[sLogModelName]
				if aAuth[sLogModelName] == token
					fEnqueue(req, res)
				else
					res.requestError('授权信息错误')
			# 授权未被缓存
			else
				async.waterfall([
					# 检验授权信息
					(cb)->
						auth.checkAuth({appID, token}, (err, bAuthorized)->
							if !err
								if bAuthorized
									cb(null, null)
								else
									cb('应用未授权')
							else
								cb('授权信息检验失败')
						)
					# 检验日志模型
					(result, cb)->
						logModel.checkLogModel({appID, sLogType}, (err, bLogModel)->
							if !err
								if bLogModel
									cb(null, null)
								else
									cb('日志模型不存在')
							else
								cb('日志模型检验失败')						
						)
				], (err, result)->
					if !err
						aAuth[sLogModelName] = token
						fEnqueue(req, res)
					else
						res.requestError(err)
				)
}