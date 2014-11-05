_ = require('lodash')

filePath = process.g.path
config = process.g.config
utils = process.g.utils


appDao = require(filePath.daos).app
APP_CONFIG = utils.getSchemaConfig('app')
APP_STATUS = APP_CONFIG.status.enumeration

module.exports = {
	# 外部接口
	create: (req, res)->
		_id = utils.createID(6)
		name = req.body.name or ''
		token = utils.createToken(name)
		appDao.getOne({name}, (err, app)->
			if !err and !app
				appDao.create({_id, name, token}, (err, raw)->
					if !err
						res.successMsg('应用授权成功')
					else
						res.errorMsg(err or '应用授权失败')
				)
			else
				res.errorMsg(err or '应用已授权')
		)
	list: (req, res)->
		query = {
			status: APP_STATUS.enable
		}
		options = {}
		appDao.list(query, options, (err, apps)->
			if !err
				res.success(apps)
			else
				res.errorMsg('授权列表获取失败')
		)
	# 内部接口
	_getByID: (id, callback)->
		appDao.getByID(id, callback)
	_getOne: (query, callback)->
		appDao.getOne(query, callback)
	# -内部接口
	# _get: (query, callback)->
	# 	appDao.get(query, callback)
	# _getOne: (query, callback)->
	# 	appDao.getOne(query, callback)
	# _listAll: (callback)->
	# 	appDao.listAll((err, aAuth)->
	# 		temp = []
	# 		if !err
	# 			_.each(aAuth, (oAuth)->
	# 				temp.push({
	# 					appName: oAuth.appName,
	# 					appID: oAuth.appID,
	# 					token: oAuth.token,
	# 					ts: oAuth.ts,
	# 					status: oAuth.status
	# 				})
	# 			)
	# 		callback(err, temp)		
	# 	)	
	# _checkAuth: (query, callback)->
	# 	appID = query.appID
	# 	token = query.token
	# 	appDao.getOne({appID, token}, (err, app)->
	# 		apporized = if app then true else false
	# 		callback(err, apporized)
	# 	)
}