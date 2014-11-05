path = require('path')
fs = require('fs-extra')
_ = require('lodash')

config = process.g.config
utils = process.g.utils
filePath = process.g.path

# 路由根目录
routesDirPath = filePath.routes
# 路由配置
routesConfigPath = path.join(routesDirPath, 'config')
# 路由文件
routesPath = path.join(routesDirPath, 'mapping')
# 路由中间件
routesMWPath = path.join(routesDirPath, 'middlewares')

mw = require(routesMWPath)
ctrl = require(filePath.controllers)

module.exports = (app)->
	# 注册mapping文件夹中的路由
	_.forEach(fs.readdirSync(routesPath), (routesFileName, index)->
		if ~routesFileName.indexOf '.js'
			ctrlName = routesFileName.replace('.js', '')
			routesFilePath = path.join(routesPath, routesFileName)
			require(routesFilePath)(app, mw, ctrl?[ctrlName])
	)
	# # 注册config文件夹中的路由
	# _.each(fs.readdirSync(routesConfigPath), (configFile, index)->
	# 	if ~configFile.indexOf '.json'
	# 		ctrlName = configFile.replace('.json','')
	# 		routesConfig = require(path.join(routesConfigPath, configFile))
	# 		_.each(routesConfig, (methodConfig, methodName)->
	# 			verb = methodConfig.verb
	# 			url = methodConfig.url
	# 			controller = ctrl[ctrlName][methodName]
	# 			app[verb](url, controller)
	# 		)
	# )