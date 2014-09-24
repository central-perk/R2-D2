path = require('path')
fs = require('fs-extra')
utils = process.g.utils
config = process.g.config
LOGFILE_STATUS = config.STATUS.LOGFILE
logsPath = process.g.logsPath
logFileDao = require(process.g.daoPath).logFile

# 返回可写日志文件的路径
fWriteableLog = (sFullLogName, callback)->
	sAppID 		= sFullLogName.split('.')[0]
	sLogName 	= sFullLogName.split('.')[1]
	logFileDao.getOne({appID: sAppID, name: sLogName, status: LOGFILE_STATUS.writeable}, (err, oLogFile)->
		if !err
			if oLogFile # 状态为可写的日志文件存在
				sLogFileName = oLogFile.fileName
				sLogFilePath = path.join(logsPath, sLogFileName)
				bLogFileSizeOK = fCheckLogSize(sLogFilePath)
				if bLogFileSizeOK
					callback(null, sLogFilePath)
				else
					logFileDao.update({fileName: sLogFileName}, {status: LOGFILE_STATUS.unstorage}, (err, doc)->
						if config.STORAGE.delay # 如果设置了延时入库
							kue = utils.getCtrl('kue')
							setTimeout(()->
								kue.enqueueStorage({
									logFileName: sLogFileName,
									status: LOGFILE_STATUS.unstorage
								})
							, config.STORAGE.delay)
					)
					# create new log file
					fCreateLogFile(sFullLogName, callback)
			else # 状态为可写的日志文件不存在，则创建新文件
				fCreateLogFile(sFullLogName, callback)
		else
			callback('日志文件查询失败')
	)

# 返回日志文件是否可以继续写入
fCheckLogSize = (sLogFilePath)->
	try 
		nSize = fs.readFileSync(sLogFilePath, 'utf8').length
		return config.LOG_MAX_SIZE > nSize
	catch e
		return false


# 返回最新创建文件的路径
fCreateLogFile = (sFullLogName, callback)->
	sAppID 		= sFullLogName.split('.')[0]
	sLogName 	= sFullLogName.split('.')[1]

	sLogFileName = "#{sFullLogName}.#{utils.getTime()}.log"

	console.log 'create', sLogFileName

	sLogFilePath = path.join(logsPath, sLogFileName)
	fs.createFileSync(sLogFilePath)
	logFileDao.create({appID: sAppID, name: sLogName, fileName: sLogFileName}, (err, raw)->
		callback(err, sLogFilePath)
	)

# 将日志写入到文件
fWriteFile = (sLogFilePath)->
	return (message, cb)->
		sLogFileName = path.basename(sLogFilePath)
		# _fileName属于私有变量需要下划线开头
		message._fileName = sLogFileName
		console.log message
		message = JSON.stringify(message, null, 0) + '\n'
		if !fs.existsSync(sLogFilePath)
			createFileSync(sLogFilePath)
		fs.writeFile(sLogFilePath, message, {
			encoding: 'utf8'
			flag:'a'
		}, cb)


module.exports = {
	write: (sFullLogName, callback)->
		fWriteableLog(sFullLogName, (err, sLogFilePath)->
			callback(err, fWriteFile(sLogFilePath))
		)
	readyStorage: (callback)->
		# 将日志文件状态从可写入转为待入库状态
		logFileDao.Model.update(
			{status: LOGFILE_STATUS.writeable},
			{status: LOGFILE_STATUS.unstorage},
			{multi: true},
			callback
		)
}

# module.exports = (sFullLogName, callback)->
# 	fWriteableLog(sFullLogName, (err, sLogFilePath)->
# 		callback(err, fWriteFile(sLogFilePath))
# 	)