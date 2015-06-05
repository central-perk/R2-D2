_ = require('lodash')
async = require('async')
mongoose = require('mongoose')
fs = require('fs-extra')

config = process.g.config
utils = process.g.utils
filePath = process.g.path
LOGGERFILE_STATUS = config.LOGGERFILE.status
STORAGE_MAXLINES = config.STORAGE.maxLines
PERPAGE = config.APP.PAGE.perPage

loggersPath = path.join(filePath.root, 'loggers')


appCtrl = utils.getCtrl('app')
logCtrl = utils.getCtrl('log')
kueCtrl = utils.getCtrl('kue')
loggerFileCtrl = utils.getCtrl('loggerFile')

# 将log文件传话为json数据格式
log2json = (data)->
	loggers = data.split('\n').slice(0, -1)
	_.forEach(loggers, (logger, index)->
		loggers[index] = JSON.parse(logger)
	)
	return loggers

# 将json文件存至数据库
json2db = (Model, loggers, callback)->
	loggersLength = loggers.length
	Model.create(loggers.slice(0, STORAGE_MAXLINES), (err, raw)->
		if !err
			if STORAGE_MAXLINES >= loggersLength
				loggerFileCtrl.updateStatus({
					_fileName: loggers[0]._fileName
					status: LOGGERFILE_STATUS.storaged
				}, callback)
			else
				# # 强制阻断
				# if loggersLength > 150
				# 	callback(null, null)
				# else
				json2db(Model, loggers.slice(STORAGE_MAXLINES), callback)
		else
			callback(err)
	)

module.exports = {
	create: (req, res)->
		appID 	= req.params.appID
		logName = req.params.logName
		token 	= req.params.token
		loggerName = "#{appID}.#{logName}"
		if !appID
			res.errorMsg('缺少应用ID')
		else if !logName
			res.errorMsg('缺少日志名称')
		else if !token
			res.errorMsg('缺少令牌')
		else
			#! TODO 读取缓存
			async.waterfall([
				# 检验授权信息
				(cb)->
					appCtrl._getOne({_id: appID, token}, (err, app)->
						if app
							cb(null, null)
						else
							cb(err or '应用授权错误')
					)
				# 检验日志模型
				(result, cb)->
					logCtrl._getOne({app: appID, name: logName}, (err, log)->
						if log
							cb(null, null)
						else
							cb(err or '日志不存在')
					)
			], (err, result)->
				if !err
					#! TODO 添加缓存
					loggerTmp = {
						appID
						logName
						loggerName
						logger: _.cloneDeep(req.query)
					}
					process.emit('enqueueLogger', loggerTmp)
					res.success({code: 200})
				else
					res.errorMsg(err)
			)
	# 日志列表
	list: (req, res)->
		query = req.query
		appID = query.app
		name = query.name
		page = Number(query.page) - 1 || 0
		loggerName = "#{appID}.#{name}"
		try
			Model = mongoose.model(loggerName)
			async.auto({
				# getTotal: (cb)->
				# 	Model.count({}, cb)
				getList: (cb)->
					Model.find({})
						.sort({_ts: -1})
						.limit(PERPAGE)
						.skip(PERPAGE * page)
						.exec(cb)
			}, (err, results)->
				if !err
					loggers = results.getList
					paging = {
						curPage: page + 1,
						noNext: loggers.length < PERPAGE
					}
					res.success({paging, loggers})
				else
					console.log err
					res.errorMsg('授权列表获取失败')
			)
		catch e
			res.errorMsg('日志列表获取失败')
	_storage: (loggerFile, callback)->
		app = loggerFile.app
		loggerName = loggerFile.name
		logName = loggerName.split('.')[1] # "#{appID}.#{logName}"
		loggerFileName = loggerFile._fileName
		loggerFilePath = path.join(loggersPath, loggerFileName)
		loggerFileStatus = loggerFile.status
		Model = mongoose.model(loggerName)
		async.waterfall([
			# 确定日志文件已经入库行数
			(cb)->
				#! TODO 对于不是unstorage状态的判断，给出警告
				if loggerFileStatus == LOGGERFILE_STATUS.unstorage
					cb(null, 0)
				else
					# TODO 添加入库中状态的判定
					Model.count({_fileName: loggerFileName}, cb)
			(line, cb)->
				# 入库前，日志文件可能被删除
				fs.readFile(loggerFilePath, 'utf-8', (err, loggers)->
					if !err
						loggers = log2json(loggers)
						loggers = loggers.slice(Number(line))
						loggerFileCtrl.updateStatus(loggerFile, (err)->
							if err
								console.log err
							if !err
								json2db(Model, loggers, cb)
							else
								cb(err)
						)
					else
						cb(err)
				)
		], callback)
}