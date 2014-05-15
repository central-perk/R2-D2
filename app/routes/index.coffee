path = require('path')
ctrl = require(path.join(process.g.controllersPath, 'mapping', 'index'))
module.exports = (app, mw)->
	app.get('/', mw.distribute)