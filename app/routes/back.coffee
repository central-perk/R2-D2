utils = process.g.utils
back = utils.getCtrl('back')
module.exports = (app, mw)->
	app.get('/back', (req, res, next)->
		req.requireAuthorization(req, res, next)
	, back.index)
	
	app.get('/back/:module', back.getContent)


	# app.all('*', (req, res, next)->
 #  		req.requireAuthorization(req, res, next)
	# )

