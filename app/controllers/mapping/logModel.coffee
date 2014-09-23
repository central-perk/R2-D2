async       = require('async')
mongoose    = require('mongoose')
_ 			= require('lodash')
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

attrLegal = (aAttr)->
	aName = _.flatten(aAttr, 'name')
	aUniqueName = _.uniq(aName)
	bAttrUnique = aName.length == aUniqueName.length
	bNameValid = true
	_.each(aAttr, (oAttr)->
		if oAttr.name.slice(0,1) == '_'
			bNameValid = false
	)
	return bAttrUnique and bNameValid

module.exports = {
	# 创建模型以后还需要注册！
	# 再创建队列的任务
	create: (req, res)->
		body 	= req.body
		appID 	= body.appID
		token 	= body.token
		sName 	= body.name
		sCname 	= body.cname
		aAttr 	= body.attr

		if !appID
			res.error('缺少应用ID')
		else if !token
			res.error('缺少token')
		else if !sName
			res.error('缺少日志名称')
		else if !sCname
			res.error('缺少日志显示名称')
		else if sName.length > 20 or sCname.length > 20
			res.error('日志名称的长度不符')
		else if !attrLegal(aAttr)
			res.error('属性不能以下划线开头，且不能重复')
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
							cb('日志创建失败')
					)
				# 查询日志是否存在
				(result, cb)->
					logModelDao.getOne({appID, name: sName}, (err, oLogModel)->
						if !err
							if !oLogModel
								cb(null, null)
							else
								cb('日志已经存在，不能重复创建')
						else
							cb('日志创建失败')
					)
				# 创建日志
				(result, cb)->
					logModelDao.create({
						appID: appID,
						name: sName,
						cname: sCname,
						attr: aAttr
					}, (err, raw)->
						if !err
							cb(null, null)
						else
							cb('日志创建失败')
					)
				# mongo注册模型
				(result, cb)->
					module.exports['register']({appID: appID, name: sName}, (err)->
						if !err
							cb(null, null)
						else 
							console.log err
							cb('日志创建成功，mongo注册失败')
					)
				# 创建队列处理日志的任务
				(result, cb)->
					kue = utils.getCtrl('kue')
					kue.processLog({appID: appID, name: sName})
					cb(null)
			],(err)->
				if !err
					res.success('日志创建成功')
				else
					res.error(err)
			)
	update: (req, res)->
		body = 		req.body
		appID = 	body.appID
		token = 	body.token
		sName = 	body.name
		sCname = 	body.cname
		aAttr = 	body.attr
		if !appID
			res.error('缺少应用ID')
		else if !token
			res.error('缺少token')
		else if !sName
			res.error('缺少日志名称')
		else if !sCname
			res.error('缺少日志显示名称')
		else if sName.length > 20 or sCname.length > 20
			res.error('日志名称的长度不符')
		else if !attrLegal(aAttr)
			res.error('参数不符合要求，检查是否重复或者包含关键词')
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
							cb('日志更新失败')
					)
				# 查询日志是否存在
				(result, cb)->
					logModelDao.getOne({appID, name: sName}, (err, oLogModel)->
						if !err
							if oLogModel
								cb(null, null)
							else
								cb('日志已经存在')
						else
							cb('日志更新失败')
					)
				# 更新日志
				(result, cb)->
					logModelDao.update({appID, name: sName}, 
						{
							cname: sCname,
							attr: aAttr
						},
						(err, raw)->
							if !err
								cb(null, null)
							else
								cb('日志更新失败')
					)
			],(err, result)->
				if !err
					res.error('日志更新成功，重启服务器以生效')
				else
					res.error(err)
			)		
	get: (req, res)->
		appID = req.query['appID']
		name = req.query['name']
		logModelDao.getOne({appID, name}, (err, oLogModel)->
			if !err
				console.log oLogModel
				res.success(oLogModel)
			else
				res.error('日志列表获取失败')
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
			sName = oLogModel.name
			sCname = oLogModel.cname
			aAttr = oLogModel.attr
			sLogModelName = "#{appID}.#{sName}"

			_.each(aAttr, (attr)->
				name = attr.name
				cname = attr.cname
				dataType = attr.dataType
				oSchema[name] = oAttrValueMap[dataType]
			)
			# 私有字段使用下划线打头
			oSchema._ts = {
				type: Date,
				get: utils.formatTime
			}
			oSchema._fileName = String
			# 日志等级
			oSchema._level = Number
			
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
				sName = oLogModel.name
				sCname = oLogModel.cname
				aAttr = oLogModel.attr
				sLogModelName = "#{appID}.#{sName}"

				_.each(aAttr, (attr)->
					name = attr.name
					cname = attr.cname
					dataType = attr.dataType
					oSchema[name] = oAttrValueMap[dataType]
				)
				oSchema.ts = {
					type: Date,
					get: utils.formatTime
				}
				oSchema.fileName = String
				# 日志等级
				oSchema.level = Number
				schema = new Schema(oSchema)
				try
					mongoose.model(sLogModelName, schema)
				catch e
			)
			aAllLogModels = _.reduce(oLogModels, (arr, oLogModel)->
				arr.push({
					appID: oLogModel.appID,
					name: oLogModel.name,
					cname: oLogModel.cname
				})
				return arr
			, [])
			callback(null, aAllLogModels)
		)
	checkLogModel: (query, callback)->
		appID = query.appID
		name = query.name
		logModelDao.getOne({appID, name}, (err, oLogModel)->
			bLogModel = if oLogModel then true else false
			callback(err, bLogModel)
		)
}