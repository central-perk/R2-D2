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
		if !err
			console.log '数据入库成功'
			done()
	)
)


module.exports = {
	enqueueLog: (oLogTemp)->
		appID = oLogTemp.appID
		sLogType = oLogTemp.type
		sLogModelName = "#{appID}.#{sLogType}"
		oLog = oLogTemp.log
		jobs.create(sLogModelName, {log: oLog}).attempts(3).save()
	processLog: (oLogModel)->
		appID = oLogModel.appID
		sLogType = oLogModel.type
		sLogModelName = "#{appID}.#{sLogType}"
		jobs.process(sLogModelName, 1, (job, done)->
			sLogModelName = job.type
			oLog = job.data.log
			logger(sLogModelName, (err, fWriteLog)->
				fWriteLog(oLog, (err)->
					if !err
						done()
				)	
			)
		)
	enqueueStorage: (oLogFile)->
		jobs.create('storage', {oLogFile}).attempts(3).save()
}