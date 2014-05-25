path = require('path')
utils = process.g.utils

ctrl = utils.getCtrl('index')
auth = utils.getCtrl('auth')
logModel = utils.getCtrl('logModel')




module.exports = (app, mw)->
	# 授权
	app.post('/auth', auth.create)
	app.get('/auth', auth.list)

	# 日志模型
	app.post('/logmodel', logModel.create)
	app.put('/logmodel', logModel.update)
	app.get('/logmodel/', logModel.get)


	# 上传日志入口，由中间件分发到对应的控制器进行处理
	app.get('/', mw.distribute)

	# 日志列表接口
	app.get('/login', ctrl.list('login'))