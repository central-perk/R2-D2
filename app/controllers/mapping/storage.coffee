# 将日志文件从文件存到数据库

fs = require('fs-extra')
path  = require('path')
_  = require('lodash')
utils = process.g.utils
logsPath = process.g.logsPath
Dao = {}

log2json = (data)->
	logs = data.split('\n').slice(0, -1)
	_.each(logs, (log, index)->
		logs[index] = JSON.parse(logs[index])
		delete logs[index].level
		delete logs[index].message
	)
	return logs

module.exports = (cb, flag)->
	logFileLength = fs.readdirSync(logsPath).length
	_.each(fs.readdirSync(logsPath), (file, index)->
		filePath = path.join(logsPath, file)
		model = file.split('.')[0]
		TS = Number(file.split('.')[1])
		if utils.getTime(new Date()) > TS || flag
			Dao[model] = require(process.g.daoPath)[model]
			logs = fs.readFileSync(filePath, 'utf-8')
			logs = log2json(logs)
			Dao[model].create(logs, (err, data)->
				if !err
					fs.deleteSync(filePath)
				else
					console.log err
					cb(err)
				# 最后一条log callback
				if logFileLength == index + 1
					cb(null)
			)
	)