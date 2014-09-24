kue = require('kue')
jobs = kue.createQueue()
utils = process.g.utils
config = process.g.config
logger = utils.getCtrl('log')
logModel = utils.getCtrl('logModel')
storage = utils.getCtrl('storage')

aDataModels = _.keys(require('mongoose').models)


# 将动态创建的日志模型创建处理队列的任务
logModel.registerAll((err, aLogModels)->
	_.each(aLogModels, (oLogModel)->
		module.exports['processLog'](oLogModel)
	)
)

# 为入库创建处理队列的任务
jobs.process('storage', config.STORAGE.maxProcess, (job, done)->
	oLogFile = job.data.oLogFile
	storage.store(oLogFile, (err)->
		console.log err or '数据入库成功'
		done()
	)
)


module.exports = {
	enqueueLog: (oLogTemp)->
		sAppID 			= oLogTemp.appID
		sLogName 		= oLogTemp.name
		sFullLogName 	= "#{sAppID}.#{sLogName}"
		oLog 			= oLogTemp.log
		jobs.create(sFullLogName, {log: oLog}).attempts(3).save()
	processLog: (oLogModel)->
		sAppID = oLogModel.appID
		sLogName = oLogModel.name
		sFullLogName 	= "#{sAppID}.#{sLogName}"
		jobs.process(sFullLogName, 1, (job, done)->
			sFullLogName = job.type
			oLog = job.data.log
			logger.write(sFullLogName, (err, fWriteLog)->
				fWriteLog(oLog, (err)->
					if !err
						done()
				)	
			)
		)
	enqueueStorage: (oLogFile)->
		jobs.create('storage', {oLogFile}).attempts(3).save()
}