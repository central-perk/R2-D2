path = require('path')
fs = require('fs-extra')
utils = process.g.utils
config = process.g.config
LOGFILE_STATUS = config.STATUS.LOGFILE
logsPath = process.g.logsPath
logFileDao = require(process.g.daoPath).logFile

# 返回可写日志文件的路径
fWriteableLog = (sLogModelName, callback)->
	appID = sLogModelName.split('.')[0]
	sLogType = sLogModelName.split('.')[1]

	logFileDao.getOne({appID, type: sLogType, status: LOGFILE_STATUS.writeable}, (err, oWriteableLog)->
		if !err
			if oWriteableLog # 状态为可写的日志文件存在
				sWriteableLog = oWriteableLog.name
				sWriteableLogPath = path.join(logsPath, sWriteableLog)
				bLogSizeOK = fCheckLogSize(sWriteableLogPath)
				if bLogSizeOK # 日志文件是否可以继续写入
					callback(null, sWriteableLogPath)
				else
					logFileDao.update({name: sWriteableLog}, {status: LOGFILE_STATUS.unstorage}, (err, doc)->
						if config.STORAGE.delay # 如果设置了延时入库
							kue = utils.getCtrl('kue')
							setTimeout(()->
								kue.enqueueStorage({
									name: sWriteableLog,
									status: LOGFILE_STATUS.unstorage
								})
							, config.STORAGE.delay)
					)
					fCreateLogFile(sLogModelName, callback)
			else # 状态为可写的日志文件不存在，则创建新文件
				fCreateLogFile(sLogModelName, callback)
		else
			callback('日志文件查询失败')
	)

# 返回日志文件是否可以继续写入
fCheckLogSize = (sWriteableLogPath)->
	nSize = fs.readFileSync(sWriteableLogPath, 'utf8').length
	return config.LOG_MAX_SIZE > nSize

# 返回最新创建文件的路径
fCreateLogFile = (sLogModelName, callback)->
	appID = sLogModelName.split('.')[0]
	sLogType = sLogModelName.split('.')[1]
	sWriteableLog = "#{sLogModelName}.#{utils.getTime()}.log"
	sWriteableLogPath = path.join(logsPath, sWriteableLog)
	fs.createFileSync(sWriteableLogPath)
	logFileDao.create({appID, type: sLogType, name: sWriteableLog}, (err, raw)->
		callback(err, sWriteableLogPath)
	)

# 将日志写入到文件
fWriteFile = (sWriteableLogPath)->
	return (message, cb)->
		sLogFileName = path.basename(sWriteableLogPath)
		message.fileName = sLogFileName
		message = JSON.stringify(message, null, 0) + '\n'
		if !fs.existsSync(sWriteableLogPath)
			createFileSync(sWriteableLogPath)
		fs.writeFile(sWriteableLogPath, message, {
			encoding: 'utf8'
			flag:'a'
		}, cb)



# module.exports = (logType, callback)->
# 	fWriteableLog(logType, (err, sWriteableLogPath)->
# 		callback(null, fWriteFile(sWriteableLogPath))	
# 	)
module.exports = (sLogModelName, callback)->
	fWriteableLog(sLogModelName, (err, sWriteableLogPath)->
		callback(err, fWriteFile(sWriteableLogPath))
	)