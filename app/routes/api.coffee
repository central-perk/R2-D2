path = require('path')
api = require(path.join(process.g.controllersPath, 'mapping', 'api'))
module.exports = (app, mw)->
	app.get('/api', api.index)
	app.get('/api/:module', api.getContent)

