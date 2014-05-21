path = require('path')
ctrl = require(path.join(process.g.controllersPath, 'mapping', 'index'))
auth = require(path.join(process.g.controllersPath, 'mapping', 'auth'))

aAuth = {}



module.exports = {
	distribute: (req, res, next)->
		console.log aAuth


		type = req.query._type
		appID = Number(req.query.appID)
		token = req.query.token
		ts = req.query.ts

		if !type
			res.requestError('缺少type')
		else if !ts
			res.requestError('缺少ts')
		else if !appID
			res.requestError('缺少appID')
		else if !token
			res.requestError('缺少token')
		else
			if aAuth.appID and aAuth.appID.token == token
				delete req.query._type
				req.type = type
				ctrl.fWriteLog(req, res)
			else
				auth.get({appID}, (err, oAuth)->
					if oAuth and oAuth.token == token
						aAuth.appID = {token}
						delete req.query._type
						req.type = type
						ctrl.fWriteLog(req, res)
				)
}