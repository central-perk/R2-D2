path = require('path')
fs = require('fs')
_ = require('lodash')
moment = require('moment')


module.exports = {
	getTime: (date)->
		config = process.g.config
		time = moment(date).utc().zone(-8).format("YYYYMMDDHHmm")
		time = time - time % config.LOG_INTERVAL
	setG: (rootPath)->
		configPath = path.join(rootPath, 'config')
		appPath = path.join(rootPath, 'app')
		libsPath = path.join(rootPath, 'libs')
		logsPath = path.join(rootPath, 'logs')
		process.g = {
			config: require(configPath),
			rootPath: rootPath,
			configPath: configPath,
			appPath: appPath,
			libsPath: libsPath,
			logsPath: logsPath
		}
		_.each(fs.readdirSync(appPath), (dir, index)->
			dirPath = path.join(appPath, dir)
			process.g[dir + 'Path'] = dirPath
		)
		libs = {}
		_.each(fs.readdirSync(libsPath), (file, index)->
			if ~file.indexOf('.js')
				fileName = file.replace('.js', '')
				libs[fileName] = path.join(libsPath, file)
		)
		process.g.libs = libs
		process.g.utils = require(libs.utils)
}