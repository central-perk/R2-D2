kue = require('kue')
jobs = kue.createQueue()
_ = require('lodash')


config = process.g.config
utils = process.g.utils
filePath = process.g.path
STORAGE_MAXPROCESS = config.STORAGE.maxProcess

logCtrl = utils.getCtrl('log')
loggerCtrl = utils.getCtrl('logger')
loggerFileCtrl = utils.getCtrl('loggerFile')


# 处理日志
processLogger = (loggerName)->
	jobs.process(loggerName, 1, (job, done)->
		loggerName = job.type
		logger = job.data.logger
		loggerFileCtrl.write(loggerName, (err, writeFile)->
			writeFile(logger, (err)->
				if err
					console.log err
				done()
			)
		)
	)

# 处理入库任务
jobs.process('storage', 1, (job, done)->
	loggerFile = job.data.loggerFile
	loggerCtrl._storage(loggerFile, (err)->
		# console.log err or "#{loggerFile.name}数据入库成功"
		done()
	)
)

# 处理日志
process.on('registerLogger', (loggerName)->
	processLogger(loggerName)
	# module.exports['processLogger'](loggerName)
)

# 创建日志任务
process.on('enqueueLogger', (loggerTmp)->
	module.exports['enqueueLogger'](loggerTmp)
)

# 创建入库任务
process.on('enqueueStorage', (loggerFile)->
	module.exports['enqueueStorage'](loggerFile)
)


module.exports = {
	# 创建日志任务
	enqueueLogger: (loggerTmp)->
		appID = loggerTmp.appID # 暂时未使用
		logName = loggerTmp.logName # 暂时未使用
		loggerName = loggerTmp.loggerName
		logger = loggerTmp.logger
		jobs.create(loggerName, {logger}).attempts(3).removeOnComplete(true).save()
	# 创建入库任务
	enqueueStorage: (loggerFile)->
		jobs.create('storage', {loggerFile}).attempts(3).removeOnComplete(true).save()
}