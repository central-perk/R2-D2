utils = process.g.utils
back = utils.getCtrl('back')
module.exports = (app, mw)->
	app.get('/back', back.index)
	app.get('/api/:module', back.getContent)

