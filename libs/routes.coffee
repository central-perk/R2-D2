fs = require('fs')
path = require('path')
_ = require('lodash')
routesPath = process.g.routesPath
Ctrl = require(process.g.controllersPath)
mw = require(path.join(routesPath, 'middlewares'))

module.exports = (app)->
	_.each(fs.readdirSync(routesPath), (file, index)->
		if ~file.indexOf '.js'
			ctrlName = file.replace('.js', '')
			if Ctrl[ctrlName] # 控制器存在
				controller = Ctrl[ctrlName]
				require(path.join(routesPath, file))(app, mw, controller)
			else
				require(path.join(routesPath, file))(app, mw)
	)