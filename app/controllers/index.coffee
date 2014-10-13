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

# # 在控制器中加入路由中间件
# getCtrlPack = (ctrlName, ctrlPath)->
# 	routesConfigPath = path.join(filePath.routes, 'config', ctrlName + '.json')
# 	data = {}
# 	if fs.existsSync(routesConfigPath)
# 		# 路由配置文件
# 		routesConfig = require(routesConfigPath)
# 		# 控制器对象
# 		ctrl = require(ctrlPath)
# 		_.each(ctrl, (method, methodName)->
# 			data[methodName] = []
# 			# 权限验证
# 			if routesConfig?[methodName]?['auth']
# 				_.forEachRight(routesConfig[methodName]['auth'], (authMethod)->
# 					data[methodName].push(wm[authMethod])
# 				)
# 			# 参数验证
# 			if routesConfig?[methodName]?['urlArg'] or routesConfig?[methodName]?['reqArg'] # 中间件hasArgs
# 				data[methodName].push(wm.hasArgs(ctrlName, methodName))
# 			# 唯一性验证
# 			if routesConfig?[methodName]?['unique']
# 				data[methodName].push(wm.isUnique(ctrlName, routesConfig[methodName]['unique']))
# 			# 方法
# 			data[methodName].push(method)
# 		)
# 	else
# 		data = require(ctrlPath)
# 	return data

_.forEach(fs.readdirSync(ctrlsPath), (ctrlFileName, index)->
	if ~ctrlFileName.indexOf '.js'
		ctrlName = ctrlFileName.replace('.js', '')
		ctrlFilePath = path.join(ctrlsPath, ctrlFileName)
		ctrl = require(ctrlFilePath)
		# 必须使用clone，否则daos会合并ctrl中的方法
		ctrlDao = _.clone(daos[ctrlName]) or {}
		ctrl = _.merge(ctrlDao, ctrl)
		module.exports[ctrlName] = ctrl

		# ctrlPack = getCtrlPack(ctrlName, ctrlPath)
		# if fs.existsSync(path.join(modelsPath, ctrlFileName)) # 控制器有对应的模型
		# 	module.exports[ctrlName] = _.extend(ctrlBase.getInstance(dao[ctrlName]), ctrlPack)
		# else # 控制器没有对应的模型
		# 	module.exports[ctrlName] = ctrlPack
)