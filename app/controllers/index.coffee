path = require('path')
fs = require('fs-extra')
_ = require('lodash')

filePath = process.g.path
config = process.g.config
utils = process.g.utils

ctrlsPath = path.join(__dirname, 'mapping')
modelsPath = path.join(filePath.models, 'mapping')
routesPath = path.join(filePath.routes, 'mapping')
daos = require(filePath.daos)
wm = require(path.join(filePath.routes, 'middlewares'))


_.forEach(fs.readdirSync(ctrlsPath), (ctrlFileName, index)->
	if ~ctrlFileName.indexOf '.js'
		ctrlName = ctrlFileName.replace('.js', '')
		ctrlFilePath = path.join(ctrlsPath, ctrlFileName)
		ctrl = require(ctrlFilePath)
		# 必须使用clone，否则daos会合并ctrl中的方法
		ctrlDao = _.clone(daos[ctrlName]) or {}
		ctrl = _.merge(ctrlDao, ctrl)
		module.exports[ctrlName] = ctrl

)