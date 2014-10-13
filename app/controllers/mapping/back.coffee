_ = require('lodash')

config = process.g.config
utils = process.g.utils
filePath = process.g.path

module.exports = {
	index: (req, res)->
		res.render('index')
}