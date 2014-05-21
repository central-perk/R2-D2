path = require('path')
utils = process.g.utils
ctrl = utils.getCtrl('index')
auth = utils.getCtrl('auth')
kue  = utils.getCtrl('kue')



aAuth = {}


fEnqueue = (req, res)->
	req.type = req.query.type
	delete req.query.type
	delete req.query.appID
	delete req.query.token
	kue(req)
	res.requestSucceed('数据提交成功')


module.exports = {
	distribute: (req, res, next)->
		type = req.query.type
		appID = Number(req.query.appID)
		token = req.query.token
		ts = req.query.ts

		if !type
			res.requestError('缺少type')
		else if !ts
			res.requestError('缺少ts')
		else if !appID
			res.requestError('缺少appID')
		else if !token
			res.requestError('缺少token')
		else
			if !require('mongoose').models[type] # 该日志类型的模型不存在
				res.requestError('日志类型不存在，请先创建')
			else
				if aAuth[appID] # 授权已经被缓存
					if aAuth[appID]['token'] == token
						fEnqueue(req, res)
					else
						res.requestError('未被授权')
				else # 授权未被缓存
					auth.get({appID}, (err, oAuth)->
						if oAuth and oAuth.token == token
							aAuth[appID] = {token}
							fEnqueue(req, res)							
						else
							res.requestError('未被授权')
					)
}