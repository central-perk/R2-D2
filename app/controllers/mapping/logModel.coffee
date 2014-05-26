async       = require('async')
mongoose    = require('mongoose')
Schema      = mongoose.Schema
logModel    = mongoose.model('logModel')
logModelDao = require(process.g.daoPath).logModel
config      = process.g.config
utils       = process.g.utils
auth 		= utils.getCtrl('auth')



oAttrValueMap = {
	String: String,
	Number: Number,
	Boolean: Boolean,
	Date: Date
}


module.exports = {
	# 创建模型以后还需要注册！
	# 再创建队列的任务
	create: (req, res)->
		appID = req.body.appID
		token = req.body.token
		sLogType = req.body.type
		aAttributes = req.body.attributes
		if !appID
			res.requestError('缺少应用ID')
		else if !token
			res.requestError('缺少token')
		else if !sLogType
			res.requestError('缺少日志类型')
		else if sLogType.length > 20
			res.requestError('日志类型的长度不符')
		else
			async.waterfall([
				# 检验是否经过授权
				(cb)->
					auth._checkAuth({appID, token}, (err, bAuthorized)->
						if !err
							if bAuthorized
								cb(null, null)
							else
								cb('应用未授权')
						else
							cb('日志模型创建失败')
					)
				# 查询日志模型是否存在
				(result, cb)->
					logModelDao.getOne({appID, type: sLogType}, (err, oLogModel)->
						if !err
							if !oLogModel
								cb(null, null)
							else
								cb('日志模型已经存在，不能重复创建')
						else
							cb('日志模型创建失败')
					)
				# 创建日志模型
				(result, cb)->
					logModelDao.create({
						appID: appID,
						type: sLogType,
						attributes: aAttributes
					}, (err, raw)->
						if !err
							cb(null, null)
						else
							cb('日志模型创建失败')
					)
				# mongo注册模型
				(result, cb)->
					module.exports['register']({appID: appID, type: sLogType}, (err)->
						if !err
							cb(null, null)
						else
							cb('日志模型创建成功，mongo注册注册失败')
					)
				# 创建队列处理日志的任务
				(result, cb)->
					kue = utils.getCtrl('kue')
					kue.processLog({appID: appID, type: sLogType})
					cb(null)
			],(err)->
				if !err
					res.requestSucceed('日志模型创建成功')
				else
					res.requestError(err)
			)
	update: (req, res)->
		appID = req.body.appID
		token = req.body.token
		sLogType = req.body.type
		aAttributes = req.body.attributes
		if !appID
			res.requestError('缺少应用ID')
		else if !token
			res.requestError('缺少token')
		else if !sLogType
			res.requestError('缺少日志类型')
		else if sLogType.length > 20
			res.requestError('日志类型的长度不符')
		else
			async.waterfall([
				# 检验是否经过授权
				(cb)->
					auth._checkAuth({appID, token}, (err, bAuthorized)->
						if !err
							if bAuthorized
								cb(null, null)
							else
								cb('应用未授权')
						else
							cb('日志模型更新失败')
					)
				# 查询日志模型是否存在
				(result, cb)->
					logModelDao.getOne({appID, type: sLogType}, (err, oLogModel)->
						if !err
							if oLogModel
								cb(null, null)
							else
								cb('请先创建日志模型已经存在')
						else
							cb('日志模型更新失败')
					)
				# 更新日志模型
				(result, cb)->
					logModelDao.update({appID, type: sLogType}, {attributes: aAttributes},
						(err, raw)->
							if !err
								cb(null, null)
							else
								cb('日志模型更新失败')
					)
			],(err, result)->
				if !err
					res.requestError('日志模型更新成功，重启服务器以生效')
				else
					res.requestError(err)
			)		
	get: (req, res)->
		appID = req.query['appID']
		type = req.query['type']
		logModelDao.getOne({appID, type}, (err, oLogModel)->
			if !err
				res.requestSucceed(oLogModel)
			else
				res.requestError('日志模型列表获取失败')
		)
	# 内部接口

	_get: (query, callback)->
		logModelDao.get(query, callback)
	_getOne: (query, callback)->
		logModelDao.getOne(query, callback)
	_listAll: (callback)->
		logModelDao.listAll(callback)
	_listAttrValue: ()->
		return _.keys(oAttrValueMap)


	listAttrValue: ()->
		return _.keys(oAttrValueMap)
	# register和registerAll需要联动地改
	register: (query, callback)->
		logModelDao.getOne(query, (err, oLogModel)->
			oSchema = {}
			appID = oLogModel.appID
			sLogType = oLogModel.type
			aAttributes = oLogModel.attributes
			sLogModelName = "#{appID}.#{sLogType}"
			_.each(aAttributes, (oAttribute)->
				key = oAttribute.key
				value = oAttribute.value
				oSchema[key] = oAttrValueMap[value]
			)
			oSchema.ts = {
				type: Date,
				get: utils.formatTime
			}
			oSchema.fileName = String
			schema = new Schema(oSchema)
			try
				mongoose.model(sLogModelName, schema)
				callback(null)
			catch err
				callback(err)
		)
	registerAll: (callback)->
		logModel.find({}, (err, oLogModels)->
			_.each(oLogModels, (oLogModel)->
				oSchema = {}
				appID = oLogModel.appID
				sLogType = oLogModel.type
				aAttributes = oLogModel.attributes
				sLogModelName = "#{appID}.#{sLogType}"
				_.each(aAttributes, (oAttribute)->
					key = oAttribute.key
					value = oAttribute.value
					oSchema[key] = oAttrValueMap[value]
				)
				oSchema.ts = {
					type: Date,
					get: utils.formatTime
				}
				oSchema.fileName = String
				schema = new Schema(oSchema)
				try
					mongoose.model(sLogModelName, schema)
				catch e
			)
			aAllLogModels = _.reduce(oLogModels, (arr, oLogModel)->
				arr.push({type: oLogModel.type, appID: oLogModel.appID})
				return arr
			, [])
			callback(null, aAllLogModels)
		)
	checkLogModel: (query, callback)->
		appID = query.appID
		type = query.sLogType
		logModelDao.getOne({appID, type}, (err, oLogModel)->
			bLogModel = if oLogModel then true else false
			callback(err, bLogModel)
		)
}