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


# 检验属性是否符合规范
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

# 属性强制小写
attrLowerCase = (attrs)->
	_.forEach(attrs, (attr, index)->
		attrs[index].fieldName = attr.fieldName.toLowerCase()
	)
	return attrs

module.exports = {
	# 创建
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
			],(err)->
				if !err
					res.successMsg('日志创建成功')
				else
					console.log err
					res.errorMsg(err)
			)
	# 获取多条
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
	# 更新
	update: (req, res)->
		logID = req.params.logID
		body = req.body
		delete body.app
		delete body.name
		delete body.ts
		logDao.updateByID(logID, body, (err, data)->
			if !err
				res.successMsg('日志更新成功，重启服务后生效')
			else
				res.errorMsg(err or '日志更新失败')
		)
	# 获取根据应用分类的日志列表
	groupApp: (req, res)->
		async.auto({
			# 获取应用
			getApps: (cb)->
				logDao.Model
					.find({}, 'app')
					.populate('app', 'name ts')
					.exec(cb)
			# 获取日志
			getLogs: (cb)->
				logDao.Model
					.aggregate([{
						$group: {
							_id: {
								app: '$app'
							}
							log: {$push: { name: '$name', labelName: '$labelName'}}
						}
					}], (err, data)->
						cb(err, data)
					)

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
	# 注册日志模型
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
					type: Date
					# get: utils.dateTimeFormat
				}
			else
				schemaObj[fieldName] = FIELD_TYPE_MAP[fieldType]
		)

		# 私有字段使用下划线打头

		# 日志创建时间
		schemaObj._ts = {
			type: Date,
			default: Date.now
			# get: utils.dateTimeFormat
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
	# 注册所有日志模型
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