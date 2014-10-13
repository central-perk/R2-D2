async       = require('async')
mongoose    = require('mongoose')
_ 			= require('lodash')
Schema      = mongoose.Schema
logModel    = mongoose.model('log')


config      = process.g.config
utils       = process.g.utils
filePath 	= process.g.path
FIELD_TYPE_MAP = config.FIELD_TYPE_MAP
LOGGER_DEFAULT_LEVEL = config.LOGGER.defaultLevel


appCtrl 	= utils.getCtrl('app')
logDao 		= utils.getDao('log')


attrLegal = (attrs)->
	name = _.flatten(attrs, 'labelName')
	uniqueNames = _.uniq(name)
	attrUnique = name.length == uniqueNames.length
	nameValid = true
	_.each(attrs, (attr)->
		if attr.fieldName.slice(0,1) == '_'
			nameValid = false
	)
	return attrUnique and nameValid

attrLowerCase = (attrs)->
	_.forEach(attrs, (attr, index)->
		attrs[index].fieldName = attr.fieldName.toLowerCase()
	)
	return attrs

module.exports = {
	create: (req, res)->
		body 	= req.body
		app 	= body.app
		name 	= body.name
		labelName = body.labelName
		attrs = attrLowerCase(body.attrs) # 日志的字段强制为小写

		if !attrLegal(attrs)
			res.errorMsg('属性不能以下划线开头，且不能重复')
		else
			async.waterfall([
				# 检验是否经过授权
				(cb)->
					appCtrl._getByID(app, (err, app)->
						if app
							cb(null, null)
						else
							cb(err or '应用未授权')
					)
				# 查询日志是否存在
				(result, cb)->
					logDao.getOne({app, name}, (err, log)->
						if !log
							cb(null, null)
						else
							cb(err or '日志已经存在，不能重复创建')
					)
				# 创建日志
				(result, cb)->
					logDao.create({app, name, labelName, attrs}, cb)
				# mongo注册模型
				(result, cb)->
					logDao.getOne({app, name}, (err, log)->
						module.exports['_register'](log, (err)->
							cb(err and '日志创建成功，mongo注册失败')
						)
					)
				# # 创建队列处理日志的任务
				# (result, cb)->
				# 	kue = utils.getCtrl('kue')
				# 	kue.processLog({appID: appID, name: sName})
				# 	cb(null)
			],(err)->
				if !err
					res.successMsg('日志创建成功')
				else
					console.log err
					res.errorMsg(err)
			)
	list: (req, res)->
		query = req.query
		options = {}
		logDao.list(query, options, (err, logs)->
			if !err
				res.success(logs)
			else
				console.log err
				res.errorMsg(err or '授权列表获取失败')
		)
	update: (req, res)->
		logID = req.params.logID
		body = req.body
		delete body.app
		delete body.name
		delete body.ts
		logDao.updateByID(logID, body, (err, data)->
			if !err
				res.successMsg('日志更新成功')
			else
				res.errorMsg(err or '日志更新失败')
		)
	groupApp: (req, res)->
		async.auto({
			getApps: (cb)->
				logDao.Model
					.find({}, 'app')
					.populate('app', 'name ts')
					.exec(cb)
			getLogs: (cb)->
				logDao.Model
					.aggregate([{
						$group: {
							_id: {
								app: '$app'
							}
							log: {$push: { name: '$name', labelName: '$labelName'}}
						}
					}], cb)

		}, (err, results)->
			# 按照应用进行分组
			apps = _.groupBy(results.getApps, (log)->
				return log.app._id
			)
			# 组装
			_.forEach(results.getLogs, (log)->
				appID = log._id.app
				log.app = apps[appID][0].app
				delete log._id
			)
			# 按照应用创建顺序排序
			results.getLogs = _.sortBy(results.getLogs, (log)->
				return log.app.ts
			)
			res.success(results.getLogs)
		)
	# 内部接口
	_register: (log, callback)->
		schemaObj = {}

		appID = log.app
		logName = log.name
		logAttrs = log.attrs
		loggerName = "#{appID}.#{logName}"

		_.forEach(logAttrs, (attr)->
			fieldName = attr.fieldName
			labelName = attr.labelName
			fieldType = attr.fieldType
			if fieldType == 'Date'
				schemaObj[fieldName] = {
					type: Date,
					get: utils.dateTimeFormat
				}
			else
				schemaObj[fieldName] = FIELD_TYPE_MAP[fieldType]
		)

		# 私有字段使用下划线打头

		# 日志创建时间
		schemaObj._ts = {
			type: Date,
			default: Date.now
			get: utils.dateTimeFormat
		}
		# 日志文件名
		schemaObj._fileName = String
		# 日志等级
		schemaObj._level = {
			type: Number,
			default: LOGGER_DEFAULT_LEVEL
		}
		
		schema = new Schema(schemaObj)
		try
			mongoose.model(loggerName, schema)
			process.emit('registerLogger', loggerName);
			callback(null)
		catch err
			callback(err)
	_registerAll: ()->
		logDao.get({}, (err, logs)->
			logLength = logs.length
			count = 0
			async.whilst(
				()->
					count < logLength
				(cb)->
					count++
					module.exports['_register'](logs[count-1], cb)
				(err, result)->
					if err
						console.log err
			)
		)
	_getOne: (query, callback)->
		logDao.getOne(query, callback)
}
# module.exports = {
# 	# 创建模型以后还需要注册！
# 	# 再创建队列的任务
# 	create: (req, res)->
# 		body 	= req.body
# 		appID 	= body.appID
# 		token 	= body.token
# 		sName 	= body.name
# 		sCname 	= body.cname
# 		attrs 	= body.attr

# 		attrs = attrLowerCase(attrs)

# 		if !appID
# 			res.error('缺少应用ID')
# 		else if !token
# 			res.error('缺少token')
# 		else if !sName
# 			res.error('缺少日志名称')
# 		else if !sCname
# 			res.error('缺少日志显示名称')
# 		else if sName.length > 20 or sCname.length > 20
# 			res.error('日志名称的长度不符')
# 		else if !attrLegal(attrs)
# 			res.error('属性不能以下划线开头，且不能重复')
# 		else
# 			async.waterfall([
# 				# 检验是否经过授权
# 				(cb)->
# 					auth._checkAuth({appID, token}, (err, bAuthorized)->
# 						if !err
# 							if bAuthorized
# 								cb(null, null)
# 							else
# 								cb('应用未授权')
# 						else
# 							cb('日志创建失败')
# 					)
# 				# 查询日志是否存在
# 				(result, cb)->
# 					logModelDao.getOne({appID, name: sName}, (err, oLogModel)->
# 						if !err
# 							if !oLogModel
# 								cb(null, null)
# 							else
# 								cb('日志已经存在，不能重复创建')
# 						else
# 							cb('日志创建失败')
# 					)
# 				# 创建日志
# 				(result, cb)->
# 					logModelDao.create({
# 						appID: appID,
# 						name: sName,
# 						cname: sCname,
# 						attr: attrs
# 					}, (err, raw)->
# 						if !err
# 							cb(null, null)
# 						else
# 							cb('日志创建失败')
# 					)
# 				# mongo注册模型
# 				(result, cb)->
# 					module.exports['register']({appID: appID, name: sName}, (err)->
# 						if !err
# 							cb(null, null)
# 						else 
# 							console.log err
# 							cb('日志创建成功，mongo注册失败')
# 					)
# 				# 创建队列处理日志的任务
# 				(result, cb)->
# 					kue = utils.getCtrl('kue')
# 					kue.processLog({appID: appID, name: sName})
# 					cb(null)
# 			],(err)->
# 				if !err
# 					res.success('日志创建成功')
# 				else
# 					res.error(err)
# 			)
# 	update: (req, res)->
# 		body = 		req.body
# 		appID = 	body.appID
# 		token = 	body.token
# 		sName = 	body.name
# 		sCname = 	body.cname
# 		attrs = 	body.attr

# 		attrs = attrLowerCase(attrs)
		
# 		if !appID
# 			res.error('缺少应用ID')
# 		else if !token
# 			res.error('缺少token')
# 		else if !sName
# 			res.error('缺少日志名称')
# 		else if !sCname
# 			res.error('缺少日志显示名称')
# 		else if sName.length > 20 or sCname.length > 20
# 			res.error('日志名称的长度不符')
# 		else if !attrLegal(attrs)
# 			res.error('参数不符合要求，检查是否重复或者包含关键词')
# 		else
# 			async.waterfall([
# 				# 检验是否经过授权
# 				(cb)->
# 					auth._checkAuth({appID, token}, (err, bAuthorized)->
# 						if !err
# 							if bAuthorized
# 								cb(null, null)
# 							else
# 								cb('应用未授权')
# 						else
# 							cb('日志更新失败')
# 					)
# 				# 查询日志是否存在
# 				(result, cb)->
# 					logModelDao.getOne({appID, name: sName}, (err, oLogModel)->
# 						if !err
# 							if oLogModel
# 								cb(null, null)
# 							else
# 								cb('日志已经存在')
# 						else
# 							cb('日志更新失败')
# 					)
# 				# 更新日志
# 				(result, cb)->
# 					logModelDao.update({appID, name: sName}, 
# 						{
# 							cname: sCname,
# 							attr: attrs
# 						},
# 						(err, raw)->
# 							if !err
# 								cb(null, null)
# 							else
# 								cb('日志更新失败')
# 					)
# 			],(err, result)->
# 				if !err
# 					res.error('日志更新成功，重启服务器以生效')
# 				else
# 					res.error(err)
# 			)		

# 	# 内部接口

# 	_get: (query, callback)->
# 		logModelDao.get(query, callback)
# 	_getOne: (query, callback)->
# 		logModelDao.getOne(query, callback)
# 	_listAll: (callback)->
# 		logModelDao.listAll(callback)
# 	_listAttrValue: ()->
# 		return _.keys(oAttrValueMap)


# 	listAttrValue: ()->
# 		return _.keys(oAttrValueMap)
# 	# register和registerAll需要联动地改
# 	register: (query, callback)->
# 		logModelDao.getOne(query, (err, oLogModel)->
# 			oSchema = {}
# 			appID = oLogModel.appID
# 			sName = oLogModel.name
# 			sCname = oLogModel.cname
# 			attrs = oLogModel.attr
# 			sLogModelName = "#{appID}.#{sName}"

# 			_.each(attrs, (attr)->
# 				name = attr.name
# 				cname = attr.cname
# 				dataType = attr.dataType
# 				if dataType == Date
# 					oSchema[name] = {
# 						type: Date,
# 						get: utils.formatTime
# 					}
# 				else
# 					oSchema[name] = oAttrValueMap[dataType]
# 			)
# 			# 私有字段使用下划线打头
# 			oSchema._ts = {
# 				type: Date,
# 				get: utils.formatTime
# 			}
# 			oSchema._fileName = String
# 			# 日志等级
# 			oSchema._level = Number
			
# 			schema = new Schema(oSchema)
# 			try
# 				mongoose.model(sLogModelName, schema)
# 				callback(null)
# 			catch err
# 				callback(err)
# 		)
# 	registerAll: (callback)->
# 		logModel.find({}, (err, oLogModels)->
# 			_.each(oLogModels, (oLogModel)->
# 				oSchema = {}
# 				appID = oLogModel.appID
# 				sName = oLogModel.name
# 				sCname = oLogModel.cname
# 				attrs = oLogModel.attr
# 				sLogModelName = "#{appID}.#{sName}"

# 				_.each(attrs, (attr)->
# 					name = attr.name
# 					cname = attr.cname
# 					dataType = attr.dataType
# 					if dataType == 'Date'
# 						oSchema[name] = {
# 							type: Date,
# 							get: utils.formatTime
# 						}
# 					else
# 						oSchema[name] = oAttrValueMap[dataType]
# 				)
# 				oSchema._ts = {
# 					type: Date,
# 					get: utils.formatTime
# 				}
# 				oSchema._fileName = String
# 				# 日志等级
# 				oSchema._level = Number
				
# 				schema = new Schema(oSchema)
# 				try
# 					mongoose.model(sLogModelName, schema)
# 				catch e
# 			)
# 			aAllLogModels = _.reduce(oLogModels, (arr, oLogModel)->
# 				arr.push({
# 					appID: oLogModel.appID,
# 					name: oLogModel.name,
# 					cname: oLogModel.cname
# 				})
# 				return arr
# 			, [])
# 			callback(null, aAllLogModels)
# 		)
# 	checkLogModel: (query, callback)->
# 		appID = query.appID
# 		name = query.name
# 		logModelDao.getOne({appID, name}, (err, oLogModel)->
# 			bLogModel = if oLogModel then true else false
# 			callback(err, bLogModel)
# 		)
# }