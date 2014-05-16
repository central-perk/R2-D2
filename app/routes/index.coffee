path = require('path')
ctrl = require(path.join(process.g.controllersPath, 'mapping', 'index'))
module.exports = (app, mw)->
	app.get('/', mw.distribute)

	
	# 谨慎使用该接口，您在强制入库的时候该文件也有可能正在被操作，可能造成数据丢失
	app.post('/storage', ctrl.storage)

	app.get('/login', ctrl.list('login'));
