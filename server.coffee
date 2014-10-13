path 	= require('path')
express = require('express')
passport = require('passport')

require('source-map-support').install();

require(path.join(__dirname, 'libs', 'utils')).setG(__dirname)

config = process.g.config
utils = process.g.utils
filePath = process.g.path


require(filePath.db).connect( 
	(mongoose)->
		app = express()

		require(filePath.passport)(passport);
		# Express配置
		require(filePath.express)(app, passport, mongoose);
		# Route配置
		require(filePath.router)(app);

		# 注册所有日志
		logCtrl = utils.getCtrl('log')
		logCtrl._registerAll()

		# # 定时任务
		# # require(filePath.cron);
		# app.get('*', (req, res)->
		# 	return res.render('index')
		# )
		app.listen app.get('port'), ()->
			console.log("Listen on port #{app.get('port')}")
)