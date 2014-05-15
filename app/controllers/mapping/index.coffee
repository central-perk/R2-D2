path = require('path')
fs = require('fs')
_ = require('lodash')
logger = require(path.join(__dirname, 'log'))
modelsPath = path.join(process.g.modelsPath , 'mapping')



module.exports = {
	openLogin: (req, res)->
		log = new logger('login')
		log(req.query)
		# logger.login()
		# log.login(req.query)
		# console.log loginDao
		res.send('ok')
}