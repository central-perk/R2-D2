path = require('path')
fs = require('fs')
_ = require('lodash')
moment = require('moment')


module.exports = {
	getTime: (date)->
		config = process.g.config
		time = moment(date).utc().zone(-8).format("YYYYMMDDHHmm")
		time = time - time % config.LOG_INTERVAL
	formatTime: (date)->
		time = moment(date).utc().zone(-8).format("YYYY-MM-DD HH:mm:ss")
	setG: (rootPath)->
		configPath = path.join(rootPath, 'config')
		appPath = path.join(rootPath, 'app')
		libsPath = path.join(rootPath, 'libs')
		logsPath = path.join(rootPath, 'logs')
		publicPath = path.join(rootPath, 'public')
		process.g = {
			config: require(configPath),
			rootPath,
			configPath,
			appPath,
			libsPath,
			logsPath,
			publicPath,
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
	pagination: (page, perPage, count)->
		pagination = {}
		pages = Math.ceil(count / perPage)
		curpage = page
		clas = page == if curpage then 'active' else 'no'
		if count <= perPage
			return null
		# 向左
		pagination.left = if (page - 1) > 1 then (page - 1) else 1
		pagination.content = []
		# 中间所有页
		for p in [0..pages]
			curpage = p
			clas = page == if curpage then 'active' else 'no'
			if page == curpage
				pagination.active = curpage
			pagination.content.push({
				pclass: clas,
				curpage: curpage,
				ptext: curpage
	        })
		# 向右
		pagination.right = if (parseInt(page) + 1) >= pages then pages else (parseInt(page) + 1);
		return pagination;
}