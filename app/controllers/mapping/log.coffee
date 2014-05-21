# 将日志写入到文件

path = require('path')
fs = require('fs-extra')
utils = process.g.utils
config = process.g.config
logsPath = process.g.logsPath




fNewestLog = (logName)->
	sNewestLog = ''
	aLogFiles = fs.readdirSync(logsPath)
	aLogFiles = _.sortBy(aLogFiles, (str)->
		num = Number(str.split('.')[2])
		return num
	)
	_.each(aLogFiles, (sFileName)->
		rPat = new RegExp(logName)
		if rPat.test(sFileName)
			sNewestLog = sFileName
	)
	if Number(sNewestLog.split('.')[1]) == Number(utils.getTime())
		return sNewestLog
	else
		return false

fLogSize = (sNewestLogPath)->
	nSize = fs.readFileSync(sNewestLogPath, 'utf8').length
	return config.LOG_MAX_SIZE > nSize

fWriteFile = (sNewestLogPath)->
	return (message, cb)->
		message = JSON.stringify(message, null, 0) + '\n'
		fs.writeFile(sNewestLogPath, message, {
			encoding: 'utf8'
			flag:'a'
		}, cb)



module.exports = (logName)->
	sNewestLogName = fNewestLog(logName) # 最新的log文件名
	bLogExists = Boolean(sNewestLogName) # 是否存在log文件
	if bLogExists # 日志文件存在
		sNewestLogPath = path.join(logsPath, sNewestLogName)
		bLogSizeOK = fLogSize(sNewestLogPath)
		if bLogSizeOK # 日志文件未超出大小
			return fWriteFile(sNewestLogPath)
		else # 日志文件超出大小
			# 创建下一个版本的log文件
			aNewestLogName = sNewestLogName.split('.')
			aNewestLogName[2] = Number(aNewestLogName[2]) + 1
			sNewestLogName = aNewestLogName.join('.')
			sNewestLogPath = path.join(logsPath, sNewestLogName) # 更新最新log文件路径
			return fWriteFile(sNewestLogPath)
	else # 日志文件不存在
		# 创建首版本的log文件
		sNewestLogName = logName + '.' + utils.getTime() + '.0.log'
		sNewestLogPath = path.join(logsPath, sNewestLogName) # 更新最新log文件路径
		return fWriteFile(sNewestLogPath)