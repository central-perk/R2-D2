# 将日志文件从文件存到数据库

fs = require('fs-extra')
path  = require('path')
_  = require('lodash')
async = require('async')
mongoose = require('mongoose')
config = process.g.config
LOGFILE_STATUS = config.STATUS.LOGFILE
utils = process.g.utils
maxLines = config.STORAGE.maxLines
logsPath = process.g.logsPath
logFileDao = require(process.g.daoPath)['logFile']

Dao = {}


# 得到需要入库的文件名
getFile = (callback)->
	logFileDao.get({status: {'$in': [20, 30]}}, (err, oLogFiles)->
		aLogFile = _.reduce(oLogFiles, (arr, oLogFile)->
			name = oLogFile.name
			status = oLogFile.status
			arr.push({name, status})
			return arr
		, [])
		callback(null, aLogFile)
	)

# 将log文件传话为json数据格式
log2json = (data)->
	logs = data.split('\n').slice(0, -1)
	_.each(logs, (log, index)->
		logs[index] = JSON.parse(logs[index])
		delete logs[index].level
		delete logs[index].message
	)
	return logs

# 更新日志文件状态
updateLogFileStatus = (sfileName, status, cb)->
	logFileDao.update({name: sfileName}, {status}, cb)

# 将json文件存至数据库
json2db = (Model, logs, callback)->
	nLen = logs.length
	Model.create(logs.slice(0, maxLines), (err, raw)->
		if !err
			if maxLines >= nLen
				updateLogFileStatus(logs[0].fileName, LOGFILE_STATUS.storaged, callback)
			else
				# # 强制阻断
				# if nLen > 150
				# 	callback(null, null)
				# else
				json2db(Model, logs.slice(maxLines), callback)
		else
			callback(err)
	)


module.exports = {
	start: ()->
		kue = utils.getCtrl('kue')
		getFile((err, aLogFile)->
			_.each(aLogFile, (oLogFile)->
				kue.enqueueStorage(oLogFile)
			)
		)
	store: (oLogFile, callback)->
		aLogFileTemp = oLogFile.name.split('.')
		appID = aLogFileTemp[0]
		sLogType = aLogFileTemp[1]
		sLogModelName = "#{appID}.#{sLogType}"
		sLogFilePath = path.join(logsPath, oLogFile.name)
		logFileStatus = oLogFile.status
		Model = mongoose.model(sLogModelName)
		async.waterfall([
			# 确定日志文件已经入库行数
			(cb)->
				if logFileStatus == LOGFILE_STATUS.unstorage
					cb(null, 0)
				else					
					Model.count({fileName: oLogFile.name}, cb)
			(nLine, cb)->
				# 入库前，日志文件可能被删除
				fs.readFile(sLogFilePath, 'utf-8', (err, logs)->
					if !err
						logs = log2json(logs)
						logs = logs.slice(Number(nLine))
						updateLogFileStatus(oLogFile.name, LOGFILE_STATUS.storaging, (err)->
							if !err
								json2db(Model, logs, cb)
							else
								cb(err)
						)
					else
						cb(err)
				)
		], callback)
}