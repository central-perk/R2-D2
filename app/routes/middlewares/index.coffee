path = require('path')
async = require('async')
basicAuth = require('connect-basic-auth')
utils = process.g.utils
ctrl = utils.getCtrl('index')
auth = utils.getCtrl('auth')
kue  = utils.getCtrl('kue')
logModel = utils.getCtrl('logModel')
aAuth = {}


fEnqueue = (req, res)->
	sAppID 		= req.params.appID
	sLogName 	= req.params.name
	oLogTemp = {
		appID: sAppID,
		name: sLogName
		log: req.body
	}
	kue.enqueueLog(oLogTemp)
	res.success('数据提交成功')

i = 1
module.exports = {
	distribute: (req, res, next)->
		oBody 		= req.body
		sAppID 		= req.params.appID
		sLogName 	= req.params.name
		sToken 		= req.params.token
		nTs 		= oBody.ts
		nLevel 		= oBody.level

		sFullLogName = "#{sAppID}.#{sLogName}"
		if !sAppID
			res.error('缺少appID')
		else if !sLogName
			res.error('缺少日志名')
		else if !sToken
			res.error('缺少秘钥')
		else if !nTs
			res.error('缺少时间戳')
		else if !nLevel
			res.error('缺少日志等级')
		else
			# 授权已经被缓存
			if aAuth[sFullLogName]
				if aAuth[sFullLogName] == sToken
					fEnqueue(req, res)
				else
					res.error('授权信息错误')
			# 授权未被缓存
			else
				async.waterfall([
					# 检验授权信息
					(cb)->
						auth._checkAuth({appID: sAppID, token: sToken}, (err, bAuthorized)->
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
						logModel.checkLogModel({appID: sAppID, name: sLogName}, (err, bLogModel)->
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
						aAuth[sFullLogName] = sToken
						fEnqueue(req, res)
					else
						res.error(err)
				)
	basicAuth: ()->
		basicAuth((credentials, req, res, next)->
			if credentials and credentials.username == "cer" and credentials.password == "site"
				next();  
			else
				if !credentials
					console.log("credentials not provided");  
				if credentials and credentials.username
					console.log("credentials-username:" + credentials.username)
				if credentials and credentials.password
					console.log("credentials-password:" + credentials.username); 
				next("Unautherized!")
    )
}