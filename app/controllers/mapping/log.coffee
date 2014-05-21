# 将日志写入到文件

path = require('path')
fs = require('fs-extra')
utils = process.g.utils
config = process.g.config
logFileStatus = config.STATUS.LOGFILE

logsPath = process.g.logsPath

logFileDao = require(process.g.daoPath)['logFile']


# 返回可写日志文件的路径
fWriteableLog = (logType, callback)->
	logFileDao.getOne({type: logType, status: logFileStatus.writeable}, (err, oWriteableLog)->
		if !err
			if oWriteableLog # 状态为可写的日志文件存在
				sWriteableLog = oWriteableLog.name
				sWriteableLogPath = path.join(logsPath, sWriteableLog)
				bLogSizeOK = fCheckLogSize(sWriteableLogPath)
				if bLogSizeOK # 日志文件是否可以继续写入
					# if config.STORAGE.delay # 如果设置了延时入库
					# 	setTimeout(create, config.STORAGE.delay)
					callback(null, sWriteableLogPath)
				else
					logFileDao.update({name: sWriteableLog}, {status: logFileStatus.unstorage}, (err, doc)->)
					fCreateLogFile(logType, callback)
			else # 状态为可写的日志文件不存在，则创建新文件
				fCreateLogFile(logType, callback)
		else
			throw err
	)

# 返回日志文件是否可以继续写入
fCheckLogSize = (sWriteableLogPath)->
	nSize = fs.readFileSync(sWriteableLogPath, 'utf8').length
	return config.LOG_MAX_SIZE > nSize

# 返回最新创建文件的路径
fCreateLogFile = (logType, callback)->
	sWriteableLog = "#{logType}.#{utils.getTime()}.log"
	sWriteableLogPath = path.join(logsPath, sWriteableLog)
	fs.createFileSync(sWriteableLogPath)
	logFileDao.create({type: logType, name: sWriteableLog}, (err, raw)->
		callback(err, sWriteableLogPath)
	)


fWriteFile = (sWriteableLogPath)->
	return (message, cb)->
		message = JSON.stringify(message, null, 0) + '\n'
		fs.writeFile(sWriteableLogPath, message, {
			encoding: 'utf8'
			flag:'a'
		}, cb)



module.exports = (logType, callback)->
	fWriteableLog(logType, (err, sWriteableLogPath)->
		callback(null, fWriteFile(sWriteableLogPath))	
	)
	# async()
	# return fWriteFile(sWriteableLogPath)

	# return (oLog, callback)->
	# 	console.log oLog
	# 	callback(null)
	# fNewestLog(logType)