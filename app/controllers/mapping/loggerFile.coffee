path = require('path')
fs = require('fs-extra')
async = require('async')

config = process.g.config
utils = process.g.utils
filePath = process.g.path

LOGGERFILE_STATUS = config.LOGGERFILE.status
LOGGERFILE_MAXSIZE = config.LOGGERFILE.maxSize

loggersPath = path.join(filePath.root, 'loggers')
loggerFileDao = utils.getDao('loggerFile')

getWriteableLoggerFilePath = (loggerName, callback)->
	appID 	= loggerName.split('.')[0]
	logName = loggerName.split('.')[1]
	async.waterfall([
		(cb)->
			loggerFileDao.getOne({
				app: appID,
				name: loggerName,
				status: LOGGERFILE_STATUS.writeable
			}, cb)
	], (err, loggerFile)->
		if loggerFile # 状态为可写的日志文件存在
			loggerFileName = loggerFile._fileName
			loggerFilePath = path.join(loggersPath, loggerFileName)
			loggerFileSizeOK = checkLogSize(loggerFilePath)
			if loggerFileSizeOK
				callback(null, loggerFilePath)
			else
				loggerFileDao.update({
					_fileName: loggerFileName
				}, {
					status: LOGGERFILE_STATUS.unstorage
				}, (err, logger)->
					process.emit('enqueueStorage', loggerFile);
					createLoggerFile(loggerName, callback)
				)
		else
			createLoggerFile(loggerName, callback)
	)

# 返回日志文件是否可以继续写入
checkLogSize = (loggerFilePath)->
	try 
		size = fs.readFileSync(loggerFilePath, 'utf8').length
		return LOGGERFILE_MAXSIZE > size
	catch e
		return false

# 返回最新创建文件的路径
createLoggerFile = (loggerName, callback)->
	appID 	= loggerName.split('.')[0]
	logName = loggerName.split('.')[1]
	loggerFileName = "#{loggerName}.#{utils.tsFormat()}.log"
	loggerFilePath = path.join(loggersPath, loggerFileName)

	fs.createFileSync(loggerFilePath)
	loggerFileDao.create({
		app: appID,
		name: loggerName,
		_fileName: loggerFileName
	}, (err, raw)->
		callback(err, loggerFilePath)
	)

# 将日志写入到文件
writeFile = (loggerFilePath)->
	return (message, cb)->
		loggerFileName = path.basename(loggerFilePath)
		message._fileName = loggerFileName
		message = JSON.stringify(message, null, 0) + '\n'
		if !fs.existsSync(loggerFilePath)
			fs.createFileSync(loggerFilePath)
		fs.writeFile(loggerFilePath, message, {
			encoding: 'utf8'
			flag:'a'
		}, cb)

module.exports = {
	write: (loggerName, callback)->
		getWriteableLoggerFilePath(loggerName, (err, loggerFilePath)->
			callback(err, writeFile(loggerFilePath))
		)
	readyStorage: (callback)->
		# 将日志文件状态从可写入转为待入库状态
		logFileDao.Model.update(
			{status: LOGFILE_STATUS.writeable},
			{status: LOGFILE_STATUS.unstorage},
			{multi: true},
			callback
		)
	updateStatus: (loggerFile, callback)->
		loggerFileName = loggerFile._fileName
		loggerFileStatus = loggerFile.status
		loggerFileDao.update({
			_fileName: loggerFileName
		}, {
			status: loggerFileStatus
		}, callback)
}