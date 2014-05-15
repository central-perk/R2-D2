path = require('path')
ctrl = require(path.join(process.g.controllersPath, 'mapping', 'index'))

module.exports = {
	distribute: (req, res, next)->
		type = req.query._type
		timestamp = req.query.timestamp
		if !type
			res.requestError('缺少type')
		else if !timestamp
			res.requestError('缺少timestamp')
		else
			if ctrl[type]
				delete req.query._type
				ctrl[type](req, res)
			else
				res.requestError('不存在该type')
}