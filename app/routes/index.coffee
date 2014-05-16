path = require('path')
ctrl = require(path.join(process.g.controllersPath, 'mapping', 'index'))
module.exports = (app, mw)->
	# 日志入口，由中间件分发到对应的控制器进行处理
	app.get('/', mw.distribute)

	
	# 强制入库，谨慎使用该接口
	# 您在强制入库的时候该文件也有可能正在被操作，可能造成数据丢失
	app.post('/storage', ctrl.storage)

	# 日志列表接口
	app.get('/login', ctrl.list('login'));
