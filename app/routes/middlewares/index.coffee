path = require('path')
async = require('async')
_ = require('lodash')
basicAuth = require('connect-basic-auth')
config = process.g.config
utils = process.g.utils
ctrl = utils.getCtrl('index')
auth = utils.getCtrl('auth')
kue  = utils.getCtrl('kue')
logModel = utils.getCtrl('logModel')
LOG_LEVEL = config.LOG.level
LOG_DEFAULT_LEVEL = LOG_LEVEL[config.LOG.defaultLevel]
aLogLevelValue = _.values(LOG_LEVEL)
oAuth = {}



fEnqueue = (req, res)->
	sAppID 		= req.params.appID
	sLogName 	= req.params.name
	oLog 		= _.cloneDeep(req.body)
	oLog._level = Number(oLog._level)

	# 添加日志生成时间
	oLog._ts 	= Number(new Date())
	# 设置日志默认等级
	if _.indexOf(aLogLevelValue, oLog._level) == -1
		oLog._level = LOG_DEFAULT_LEVEL

	oLogTemp = {
		appID: sAppID
		name: sLogName
		log: oLog
	}
	kue.enqueueLog(oLogTemp)
	res.success('数据提交成功')

i = 1
module.exports = {
	distribute: (req, res, next)->
		oBody 		= req.body
		# oParams 	= req.body.params
		sAppID 		= req.params.appID
		sLogName 	= req.params.name
		sToken 		= req.params.token

		sFullLogName = "#{sAppID}.#{sLogName}"
		if !sAppID
			res.error('缺少appID')
		else if !sLogName
			res.error('缺少日志名')
		else if !sToken
			res.error('缺少秘钥')
		else
			# 授权已经被缓存
			if oAuth[sFullLogName]
				if oAuth[sFullLogName] == sToken
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
						oAuth[sFullLogName] = sToken
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